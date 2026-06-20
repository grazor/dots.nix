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
    sopsAgeSecretName = lib.escapeShellArg cfg.sopsAgeSecretName;
    components = lib.escapeShellArg (lib.concatStringsSep "," cfg.components);
    componentsExtra = lib.escapeShellArg (lib.concatStringsSep "," cfg.componentsExtra);
  in {
    options.grazor.flux = {
      enable = mkEnableOption "Flux bootstrap from an external Git repository";

      repository = mkOption {
        type = types.str;
        example = "ssh://git@github.com/example/homelab-manifests.git";
        description = "SSH URL of the Git repository containing Flux/k3s manifests.";
      };

      branch = mkOption {
        type = types.str;
        default = "main";
        description = "Git branch Flux should reconcile.";
      };

      path = mkOption {
        type = types.str;
        default = "./clusters/homelab";
        description = "Path inside the manifests repository to reconcile.";
      };

      namespace = mkOption {
        type = types.str;
        default = "flux-system";
        description = "Namespace where Flux is installed.";
      };

      sourceName = mkOption {
        type = types.str;
        default = "homelab";
        description = "Name of the Flux GitRepository source.";
      };

      kustomizationName = mkOption {
        type = types.str;
        default = "homelab";
        description = "Name of the root Flux Kustomization.";
      };

      interval = mkOption {
        type = types.str;
        default = "1m";
        description = "Reconciliation interval for the GitRepository and Kustomization.";
      };

      deployKeySecretName = mkOption {
        type = types.str;
        default = "homelab-git";
        description = "Kubernetes Secret name for the Git deploy key.";
      };

      sopsAgeSecretName = mkOption {
        type = types.str;
        default = "sops-age";
        description = "Kubernetes Secret name containing Flux's SOPS age key.";
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

      sops.secrets = {
        "flux-deploy-key".mode = "0400";
        "flux-sops-age-key".mode = "0400";
      };

      environment.systemPackages = [pkgs.fluxcd];

      systemd.services.flux-bootstrap = {
        description = "Bootstrap Flux from the homelab manifests repository";
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

          ${kubectl} get namespace ${namespace} >/dev/null 2>&1 || ${kubectl} create namespace ${namespace}

          ${kubectl} -n ${namespace} create secret generic ${sopsAgeSecretName} \
            --from-file=age.agekey=${config.sops.secrets."flux-sops-age-key".path} \
            --dry-run=client \
            -o yaml | ${kubectl} apply -f -

          ${flux} install \
            --namespace=${namespace} \
            --components=${components} \
            ${optionalString (cfg.componentsExtra != []) "--components-extra=${componentsExtra} \\"}
            ${optionalString (!cfg.networkPolicy) "--network-policy=false \\"}
            ${optionalString (!cfg.watchAllNamespaces) "--watch-all-namespaces=false \\"}
            --export | ${kubectl} apply -f -

          ${kubectl} -n ${namespace} rollout status deploy/source-controller --timeout=5m
          ${kubectl} -n ${namespace} rollout status deploy/kustomize-controller --timeout=5m

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
            --decryption-provider=sops \
            --decryption-secret=${sopsAgeSecretName} \
            --export | ${kubectl} apply -f -
        '';
      };
    };
  };
}
