{
  pkgs,
  lib,
  config,
  ...
}: let
  userGroup = config.grazor.user.group;
  userHome = config.grazor.user.home;
  cfg = config.grazor.linux;
  opt = "k3sServer";

  my-kubernetes-helm = with pkgs;
    wrapHelm kubernetes-helm {
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
  options.grazor.linux.${opt} = lib.mkEnableOption "with k3s server";
  config = lib.mkIf cfg.${opt} {
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
      role = "server";
      extraFlags = toString [
        "--write-kubeconfig-group=${userGroup}"
        "--write-kubeconfig-mode=544"
        "--disable=traefik"
        "--disable=servicelb"
        "--node-label=hass=zigbee"
        #"--disable-network-policy"
      ];

      # multi-node server node
      tokenFile = userHome + "/.token.k3s";
      clusterInit = true;
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
}
