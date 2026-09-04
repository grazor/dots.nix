# k3s homelab cluster.
#   - k3s-base : tooling + storage shims + token (sops) shared by all nodes
#   - k3s-server : control-plane (Dell)
#   - k3s-agent : worker (Asus)
#   - k3s-nas : storage worker tainted for NAS-bound workloads only
{
  flake.modules.nixos = {
    k3s-base = {
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
      # k3s join token, decrypted on-device by sops-nix. Every node is a
      # recipient of secrets/k3s.yaml, so that file holds nothing else.
      sops.secrets."k3s-token".restartUnits = ["k3s.service"];

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

      # kubelet (10250/tcp) and flannel VXLAN (8472/udp) between nodes;
      # pod/CNI traffic flows over trusted interfaces.
      networking.firewall = {
        allowedTCPPorts = [10250];
        allowedUDPPorts = [8472];
        trustedInterfaces = ["cni0" "flannel.1"];
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

    k3s-server = {
      # API server, used by the agents and kubectl from the LAN.
      networking.firewall.allowedTCPPorts = [6443];

      # Control-plane-only material lives in secrets/server.yaml, whose only
      # recipients are the admin key and this node — the agents are recipients
      # of secrets/k3s.yaml and must not be able to read these.
      #
      # The `code` key (cloud@hl-dell-node1) pushes to the homelab manifests
      # repo. Not ~/.ssh/id_ed25519: it is a purpose-specific key, so point git
      # at it explicitly (git -c core.sshCommand, or ~/.ssh/config).
      sops.secrets."code-ssh-key" = {
        sopsFile = ../../secrets/server.yaml;
        owner = "cloud";
        path = "/home/cloud/.ssh/k3s-flux";
        mode = "0600";
      };

      # Sealed Secrets controller key. Nothing here installs it: create the TLS
      # secret by hand from this path (see README) — the controller owns it
      # from then on.
      sops.secrets."k3s-sealed-secrets-private" = {
        sopsFile = ../../secrets/server.yaml;
        owner = "cloud";
        mode = "0400";
      };

      # Its cert is public by design: kept in the clear so `kubeseal --cert`
      # works without the age key.
      environment.etc."sealed-secrets.crt".source = ./data/sealed-secrets.crt;

      services.k3s = {
        role = "server";
        clusterInit = true;
        extraFlags = toString [
          "--write-kubeconfig-group=users"
          "--write-kubeconfig-mode=640"
          "--disable=traefik"
          "--disable=servicelb"
        ];
      };
    };

    k3s-agent = {
      services.k3s = {
        role = "agent";
        serverAddr = "https://192.168.2.2:6443";
      };
    };

    k3s-nas = {
      # No node-role.kubernetes.io/* here: kubelet refuses to self-assign
      # labels in the kubernetes.io namespace and exits, taking k3s with it.
      # The cosmetic ROLES entry is set from the server instead:
      #   kubectl label node nas node-role.kubernetes.io/nas=true
      services.k3s.extraFlags = toString [
        "--node-label=storage=nas"
        "--node-taint=storage=nas:NoSchedule"
      ];
    };
  };
}
