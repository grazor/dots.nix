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

    k3s-server = {
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

    k3s-agent = {
      services.k3s = {
        role = "agent";
        serverAddr = "https://192.168.2.2:6443";
      };
    };

    k3s-nas = {
      services.k3s.extraFlags = toString [
        "--node-label=storage=nas"
        "--node-label=node-role.kubernetes.io/nas=true"
        "--node-taint=storage=nas:NoSchedule"
      ];
    };
  };
}
