# Homebuilt NAS — homelab k3s storage worker (ZFS, headless, user `cloud`).
{mkNixos, ...}: {
  flake.nixosConfigurations.nas = mkNixos {
    aspects = m:
      with m; [
        common
        proxy
        docker
        graphics-intel
        udev
        headless
        k3s-base
        k3s-agent
        k3s-nas
        ssh-server
        sops
        tools
        devtools
        fonts
        user-cloud
      ];

    machine = {
      lib,
      pkgs,
      ...
    }: {
      networking.hostName = "nas";
      networking.hostId = "e279419f";
      system.stateVersion = "25.05";
      nix.settings.max-jobs = lib.mkDefault 4;

      systemd.tpm2.enable = false;
      services = {
        resolved.enable = lib.mkForce false;

        zfs = {
          autoScrub = {
            enable = true;
            pools = ["tank"];
            interval = "weekly";
          };
          trim.enable = true;
        };

        smartd = {
          enable = true;
          autodetect = true;
          notifications.wall.enable = true;
        };
      };

      # Regenerate on the device:
      #   sudo nixos-facter -o modules/hosts/nas/facter.json
      facter.reportPath = ./facter.json;

      # Keep ZFS on the newest kernel package set this nixpkgs supports cleanly.
      boot = {
        kernelPackages = pkgs.linuxPackages;
        supportedFilesystems = ["zfs"];
        zfs = {
          forceImportRoot = false;
          extraPools = ["tank"];
        };
      };

      # Replace these UUIDs after partitioning the OS SSD.
      fileSystems = {
        "/" = {
          device = "/dev/disk/by-uuid/REPLACE_ME_ROOT_UUID";
          fsType = "ext4";
        };
        "/boot" = {
          device = "/dev/disk/by-uuid/REPLACE_ME_BOOT_UUID";
          fsType = "vfat";
          options = ["fmask=0077" "dmask=0077"];
        };

        # Create these datasets on the data HDD before switching:
        #
        #   sudo zpool create -o ashift=12 \
        #     -O acltype=posixacl -O xattr=sa -O compression=zstd \
        #     -O atime=off -O mountpoint=none tank /dev/disk/by-id/<hdd>
        #   sudo zfs create -o mountpoint=/srv/nas/appdata tank/appdata
        #   sudo zfs create -o mountpoint=/srv/nas/media tank/media
        #   sudo zfs create -o mountpoint=/srv/nas/immich tank/immich
        #   sudo zfs create -o mountpoint=/srv/nas/seafile tank/seafile
        "/srv/nas/appdata" = {
          device = "tank/appdata";
          fsType = "zfs";
        };
        "/srv/nas/media" = {
          device = "tank/media";
          fsType = "zfs";
        };
        "/srv/nas/immich" = {
          device = "tank/immich";
          fsType = "zfs";
        };
        "/srv/nas/seafile" = {
          device = "tank/seafile";
          fsType = "zfs";
        };
      };

      environment.systemPackages = with pkgs; [
        hdparm
        lm_sensors
        smartmontools
      ];

      systemd.tmpfiles.rules = [
        "d /srv/nas 0755 root root -"
        "d /srv/nas/appdata 0755 cloud users -"
        "d /srv/nas/appdata/bazarr 0755 cloud users -"
        "d /srv/nas/appdata/immich-machine-learning 0755 cloud users -"
        "d /srv/nas/appdata/jellyfin 0755 cloud users -"
        "d /srv/nas/appdata/jellyseerr 0755 cloud users -"
        "d /srv/nas/appdata/prowlarr 0755 cloud users -"
        "d /srv/nas/appdata/qbittorrent 0755 cloud users -"
        "d /srv/nas/appdata/radarr 0755 cloud users -"
        "d /srv/nas/appdata/readarr 0755 cloud users -"
        "d /srv/nas/appdata/sonarr 0755 cloud users -"
        "d /srv/nas/immich 0755 cloud users -"
        "d /srv/nas/media 0755 cloud users -"
        "d /srv/nas/media/books 0755 cloud users -"
        "d /srv/nas/media/downloads 0755 cloud users -"
        "d /srv/nas/media/downloads/complete 0755 cloud users -"
        "d /srv/nas/media/downloads/incomplete 0755 cloud users -"
        "d /srv/nas/media/movies 0755 cloud users -"
        "d /srv/nas/media/tv 0755 cloud users -"
        "d /srv/nas/seafile 0755 cloud users -"
      ];

      powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    };
  };
}
