# k3s homelab cluster.
#   - k3s-base : tooling + storage shims + token (sops) shared by all nodes
#   - k3s-server : control-plane (Dell)
#   - k3s-agent : worker (Asus)
{
  flake.modules.nixos.k3s-base = {
    pkgs,
    config,
    ...
  }: let
    my-kubernetes-helm = pkgs.wrapHelm pkgs.kubernetes-helm {
      plugins = with pkgs.kubernetes-helmPlugins; [
        helm-secrets
        helm-diff
        helm-s3
        helm-git
      ];
    };
    my-helmfile = pkgs.helmfile-wrapped.override {
      inherit (my-kubernetes-helm) pluginsDir;
    };
  in {
    # k3s join token, decrypted on-device by sops-nix.
    sops.secrets."k3s-token" = {};

    environment.systemPackages = with pkgs;
      [
        nfs-utils
        fluxcd
        cmctl
        kubeseal
        samba
        cifs-utils
      ]
      ++ [my-kubernetes-helm my-helmfile];

    services.openiscsi = {
      enable = true;
      name = "${config.networking.hostName}-initiatorhost";
    };

    services.k3s = {
      enable = true;
      tokenFile = config.sops.secrets."k3s-token".path;
    };

    systemd.tmpfiles.rules = [
      "L+ /usr/local/bin/iscsiadm - - - - /run/current-system/sw/bin/iscsiadm"
      "L+ /usr/bin/iscsiadm - - - - /run/current-system/sw/bin/iscsiadm"
      "L+ /usr/sbin/iscsiadm - - - - /run/current-system/sw/bin/iscsiadm"

      "L+ /usr/local/bin/mount.nfs - - - - /run/current-system/sw/bin/mount.nfs"
      "L+ /usr/local/bin/mount.nfs4 - - - - /run/current-system/sw/bin/mount.nfs4"
      "L+ /usr/bin/mount.nfs - - - - /run/current-system/sw/bin/mount.nfs"
      "L+ /usr/bin/mount.nfs4 - - - - /run/current-system/sw/bin/mount.nfs4"

      # Filesystem tools (mkfs/resize for volume expansion)
      "L+ /usr/local/bin/mkfs.ext4 - - - - /run/current-system/sw/bin/mkfs.ext4"
      "L+ /usr/local/bin/mkfs.xfs - - - - /run/current-system/sw/bin/mkfs.xfs"
      "L+ /usr/bin/mkfs.ext4 - - - - /run/current-system/sw/bin/mkfs.ext4"
      "L+ /usr/bin/mkfs.xfs - - - - /run/current-system/sw/bin/mkfs.xfs"

      # nsenter itself (some components call the host nsenter)
      "L+ /usr/local/bin/nsenter - - - - /run/current-system/sw/bin/nsenter"
      "L+ /usr/bin/nsenter - - - - /run/current-system/sw/bin/nsenter"

      # blkid (device identification)
      "L+ /usr/local/bin/blkid - - - - /run/current-system/sw/bin/blkid"
      "L+ /usr/bin/blkid - - - - /run/current-system/sw/bin/blkid"
    ];
  };

  flake.modules.nixos.k3s-server = {
    services.k3s = {
      role = "server";
      clusterInit = true;
      extraFlags = toString [
        "--write-kubeconfig-group=users"
        "--write-kubeconfig-mode=544"
        "--disable=traefik"
        "--disable=servicelb"
        "--node-label=hass=zigbee"
      ];
    };
  };

  flake.modules.nixos.k3s-agent = {
    services.k3s = {
      role = "agent";
      serverAddr = "https://192.168.2.2:6443";
    };
  };

  # Flux bootstrap for the Sealed-Secrets-based homelab cluster. On the k3s
  # server it restores the Sealed Secrets controller key (so the SealedSecrets
  # committed in the manifests repo decrypt) and creates the Flux GitRepository
  # + root Kustomization, mirroring `scripts/setup.sh` /
  # `cluster/flux-system/gotk-sync.yaml`. In-cluster decryption is handled by
  # the sealed-secrets controller, not Flux SOPS.
  flake.modules.nixos.flux-bootstrap = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.grazor.flux;
    inherit (lib) mkEnableOption mkIf mkOption optionalString types;

    flux = lib.getExe pkgs.fluxcd;
    kubectl = "${config.services.k3s.package}/bin/k3s kubectl";

    repo = lib.escapeShellArg cfg.repository;
    branch = lib.escapeShellArg cfg.branch;
    path = lib.escapeShellArg cfg.path;
    interval = lib.escapeShellArg cfg.interval;
    namespace = lib.escapeShellArg cfg.namespace;
    sourceName = lib.escapeShellArg cfg.sourceName;
    kustomizationName = lib.escapeShellArg cfg.kustomizationName;
    deployKeySecretName = lib.escapeShellArg cfg.deployKeySecretName;
    sealedNamespace = lib.escapeShellArg cfg.sealedSecrets.namespace;
    sealedSecretName = lib.escapeShellArg cfg.sealedSecrets.secretName;
    components = lib.escapeShellArg (lib.concatStringsSep "," cfg.components);
    componentsExtra = lib.escapeShellArg (lib.concatStringsSep "," cfg.componentsExtra);
  in {
    options.grazor.flux = {
      enable = mkEnableOption "Flux bootstrap for the homelab cluster";

      repository = mkOption {
        type = types.str;
        default = "ssh://git@github.com/grazor/homelab";
        description = "SSH URL of the Git repository containing Flux/k3s manifests.";
      };

      branch = mkOption {
        type = types.str;
        default = "main";
        description = "Git branch Flux should reconcile.";
      };

      path = mkOption {
        type = types.str;
        default = "./cluster";
        description = "Path inside the manifests repository to reconcile.";
      };

      namespace = mkOption {
        type = types.str;
        default = "flux-system";
        description = "Namespace where Flux is installed.";
      };

      sourceName = mkOption {
        type = types.str;
        default = "flux-system";
        description = "Name of the Flux GitRepository source (matches gotk-sync.yaml).";
      };

      kustomizationName = mkOption {
        type = types.str;
        default = "flux-system";
        description = "Name of the root Flux Kustomization (matches gotk-sync.yaml).";
      };

      interval = mkOption {
        type = types.str;
        default = "1m";
        description = "Reconciliation interval for the GitRepository and Kustomization.";
      };

      deployKeySecretName = mkOption {
        type = types.str;
        default = "flux-system";
        description = "Kubernetes Secret name for the Git deploy key (gotk-sync secretRef).";
      };

      sealedSecrets = {
        namespace = mkOption {
          type = types.str;
          default = "sealed-secrets";
          description = "Namespace of the sealed-secrets controller.";
        };
        secretName = mkOption {
          type = types.str;
          default = "graz-sealed-key";
          description = "TLS Secret name holding the sealed-secrets controller key.";
        };
      };

      components = mkOption {
        type = with types; listOf str;
        default = [
          "source-controller"
          "kustomize-controller"
          "helm-controller"
          "notification-controller"
        ];
        description = "Flux controller components to install.";
      };

      componentsExtra = mkOption {
        type = with types; listOf str;
        default = [];
        description = "Extra Flux controller components to install.";
      };

      networkPolicy = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Flux network policies.";
      };

      watchAllNamespaces = mkOption {
        type = types.bool;
        default = true;
        description = "Allow Flux controllers to watch all namespaces.";
      };
    };

    config = mkIf cfg.enable {
      assertions = [
        {
          assertion = config.services.k3s.enable && config.services.k3s.role == "server";
          message = "grazor.flux.enable must only be used on the k3s server node.";
        }
      ];

      # Decrypted on-device by sops-nix; consumed only by the bootstrap service.
      sops.secrets = {
        "flux-deploy-key".mode = "0400";
        "sealed-secrets-tls-crt".mode = "0400";
        "sealed-secrets-tls-key".mode = "0400";
      };

      environment.systemPackages = [pkgs.fluxcd];

      systemd.services.flux-bootstrap = {
        description = "Restore Sealed Secrets key and bootstrap Flux for the homelab cluster";
        wantedBy = ["multi-user.target"];
        wants = ["network-online.target" "k3s.service"];
        after = ["network-online.target" "k3s.service"];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };

        path = [
          pkgs.coreutils
          pkgs.fluxcd
          config.services.k3s.package
        ];

        script = ''
          set -euo pipefail

          export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

          until ${kubectl} get --raw=/readyz >/dev/null 2>&1; do
            sleep 2
          done

          # 1. Restore the Sealed Secrets controller key so that the
          #    SealedSecrets committed in the manifests repo can be decrypted.
          ${kubectl} get namespace ${sealedNamespace} >/dev/null 2>&1 || ${kubectl} create namespace ${sealedNamespace}

          ${kubectl} -n ${sealedNamespace} create secret tls ${sealedSecretName} \
            --cert=${config.sops.secrets."sealed-secrets-tls-crt".path} \
            --key=${config.sops.secrets."sealed-secrets-tls-key".path} \
            --dry-run=client \
            -o yaml | ${kubectl} apply -f -

          ${kubectl} -n ${sealedNamespace} label secret ${sealedSecretName} \
            sealedsecrets.bitnami.com/sealed-secrets-key=active --overwrite

          # 2. Install Flux controllers.
          ${kubectl} get namespace ${namespace} >/dev/null 2>&1 || ${kubectl} create namespace ${namespace}

          ${flux} install \
            --namespace=${namespace} \
            --components=${components} \
            ${optionalString (cfg.componentsExtra != []) "--components-extra=${componentsExtra} \\"}
            ${optionalString (!cfg.networkPolicy) "--network-policy=false \\"}
            ${optionalString (!cfg.watchAllNamespaces) "--watch-all-namespaces=false \\"}
            --export | ${kubectl} apply -f -

          ${kubectl} -n ${namespace} rollout status deploy/source-controller --timeout=5m
          ${kubectl} -n ${namespace} rollout status deploy/kustomize-controller --timeout=5m

          # 3. Git deploy key + GitRepository + root Kustomization
          #    (equivalent to cluster/flux-system/gotk-sync.yaml).
          ${flux} create secret git ${deployKeySecretName} \
            --namespace=${namespace} \
            --url=${repo} \
            --private-key-file=${config.sops.secrets."flux-deploy-key".path} \
            --export | ${kubectl} apply -f -

          ${flux} create source git ${sourceName} \
            --namespace=${namespace} \
            --url=${repo} \
            --branch=${branch} \
            --interval=${interval} \
            --secret-ref=${deployKeySecretName} \
            --export | ${kubectl} apply -f -

          ${flux} create kustomization ${kustomizationName} \
            --namespace=${namespace} \
            --source=GitRepository/${sourceName}.${namespace} \
            --path=${path} \
            --prune=true \
            --interval=${interval} \
            --export | ${kubectl} apply -f -
        '';
      };
    };
  };
}
