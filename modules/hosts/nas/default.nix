# Homebuilt NAS — homelab k3s storage worker (ZFS, headless, user `cloud`).
#
# Disks and pools:
#   SSD  ESP + zpool `rpool`   NixOS, app configs (/srv/nas/appdata) and immich's
#                              own Postgres (/srv/nas/db/immich). No Longhorn on
#                              this node: nas-pinned pods use plain hostPaths.
#   HDD  zpool `tank`          precious data. A single WD Red today; when the
#                              second disk arrives, `zpool attach` turns it into a
#                              mirror online. Never `zpool add` a bare disk here.
#   HDD  zpool `bulk` (later)  2x4TB stripe for disposable media. tank/media is
#                              zfs-sent there and only its entry below changes.
#
# Every dataset is mountpoint=legacy and listed in `datasets`, so NixOS imports
# the pools itself and mounts them before k3s/Samba start. The homelab repo talks
# to this node only through the /srv/nas/* hostPaths, which never move.
#
# One-time setup from the installer (fix the by-id names, then nixos-install):
#
#   SSD=/dev/disk/by-id/<ssd>; HDD=/dev/disk/by-id/<wd-red>
#   sgdisk -Z $SSD
#   sgdisk -n1:0:+1G -t1:EF00 -c1:ESP   $SSD
#   sgdisk -n2:0:0   -t2:BF00 -c2:rpool $SSD
#   mkfs.vfat -F32 -n ESP ${SSD}-part1
#   zpool create -o ashift=12 -o autotrim=on -O compression=zstd -O atime=off \
#     -O xattr=sa -O acltype=posixacl -O normalization=formD -O mountpoint=none \
#     rpool ${SSD}-part2
#   zfs create -o mountpoint=legacy rpool/root
#   zfs create -o mountpoint=legacy rpool/nix
#   zfs create -o mountpoint=legacy rpool/appdata
#   zfs create -o canmount=off rpool/db
#   zfs create -o mountpoint=legacy -o recordsize=16K rpool/db/immich
#
#   zpool create -o ashift=12 -o autoexpand=on -O compression=lz4 -O atime=off \
#     -O xattr=sa -O acltype=posixacl -O normalization=formD -O mountpoint=none \
#     tank $HDD
#   zfs create -o mountpoint=legacy -o recordsize=1M tank/immich
#   zfs create -o mountpoint=legacy -o recordsize=1M tank/media
#   for d in backup shared; do
#     zfs create -o mountpoint=legacy -o compression=zstd tank/$d
#   done
#   zfs create -o canmount=off tank/home
#   zfs create -o canmount=off tank/photos
#   zfs create -o mountpoint=legacy -o recordsize=1M tank/photos/shared
#   for u in <members>; do
#     zfs create -o mountpoint=legacy -o compression=zstd tank/home/$u
#     zfs create -o mountpoint=legacy -o recordsize=1M tank/photos/$u
#   done
#   zfs create -o canmount=off tank/replica     # syncoid target for rpool
#
# Later:
#   zpool attach tank $HDD /dev/disk/by-id/<hdd2>                  # tank -> mirror
#   zpool create -o ashift=12 -O compression=lz4 -O atime=off -O xattr=sa \
#     -O acltype=posixacl -O normalization=formD -O mountpoint=none \
#     bulk /dev/disk/by-id/<hdd3> /dev/disk/by-id/<hdd4>
#   zfs snapshot tank/media@m1
#   zfs send tank/media@m1 | zfs recv -u -o mountpoint=legacy bulk/media
#   # stop the media pods, then catch up and cut over:
#   zfs snapshot tank/media@m2
#   zfs send -i @m1 tank/media@m2 | zfs recv bulk/media
#   # point "/srv/nas/media" below at bulk/media, add bulk to autoScrub,
#   # rebuild, then: zfs destroy -r tank/media
#
# Samba keeps its own password database. Once per member, and once for the
# visitor login `guest`, on the box:
#   sudo smbpasswd -a <member>
#
# Incus (throwaway dev containers) keeps its instances on rpool/incus, a
# dataset it creates itself on first start; it is not in the list above and
# nothing snapshots or replicates it. Precious files belong in /share.
{mkNixos, ...}: {
  flake.nixosConfigurations.nas = mkNixos {
    aspects = m:
      with m; [
        common
        proxy
        docker
        incus
        graphics-intel
        udev
        headless
        k3s-base
        k3s-agent
        k3s-nas
        ssh-server
        sops
        tools
        mediatools
        devtools
        fonts
        user-cloud
      ];

    machine = {
      lib,
      pkgs,
      ...
    }: let
      # People with a personal share and a photo library. uids are pinned
      # because hostPath ownership has to survive a reinstall. Each person's
      # immich storage label must equal their username here.
      members = {
        graz = 2001;
        po = 2002;
      };
      memberNames = lib.attrNames members;
      familyGid = 2000;

      # mountpoint -> dataset. Legacy mounts: add a line, create the dataset,
      # rebuild. Moving media to `bulk` is a one-word change here.
      datasets =
        {
          "/" = "rpool/root";
          "/nix" = "rpool/nix";
          "/srv/nas/appdata" = "rpool/appdata";
          "/srv/nas/db/immich" = "rpool/db/immich";
          "/srv/nas/immich" = "tank/immich";
          "/srv/nas/media" = "tank/media";
          "/srv/nas/backup" = "tank/backup";
          "/srv/nas/shared" = "tank/shared";
          "/srv/nas/photos/shared" = "tank/photos/shared";
        }
        // lib.listToAttrs (lib.concatMap (u: [
            (lib.nameValuePair "/srv/nas/home/${u}" "tank/home/${u}")
            (lib.nameValuePair "/srv/nas/photos/${u}" "tank/photos/${u}")
          ])
          memberNames);

      # hostPath config dirs the homelab media/immich manifests expect.
      appdataDirs = [
        "bazarr"
        "immich-machine-learning"
        "jellyfin"
        "prowlarr"
        "qbittorrent"
        "radarr"
        "readarr"
        "sabnzbd"
        "seerr"
        "sonarr"
      ];

      # Group-writable share: everyone in `family` sees each other's files.
      familyShare = path: {
        inherit path;
        "valid users" = "@family";
        "read only" = "no";
        "force group" = "family";
        "create mask" = "0664";
        "directory mask" = "2775";
      };
    in {
      networking.hostName = "nas";
      networking.hostId = "e279419f";
      system.stateVersion = "25.05";
      nix.settings.max-jobs = lib.mkDefault 4;

      # Regenerate on the device:
      #   sudo nixos-facter -o modules/hosts/nas/facter.json
      facter.reportPath = ./facter.json;

      boot = {
        # Keep ZFS on the default kernel package set this nixpkgs supports.
        kernelPackages = pkgs.linuxPackages;
        supportedFilesystems = ["zfs"];
        # Root lives on rpool; the hostId above lets it import without -f.
        zfs.forceImportRoot = false;
        # Cap ARC so kubelet's memory accounting keeps room for immich-ml and
        # Jellyfin. Raise once the box's RAM is known.
        kernelParams = ["zfs.zfs_arc_max=4294967296"];
      };

      fileSystems =
        lib.mapAttrs (_: device: {
          inherit device;
          fsType = "zfs";
        })
        datasets
        // {
          "/boot" = {
            device = "/dev/disk/by-label/ESP";
            fsType = "vfat";
            options = ["fmask=0077" "dmask=0077"];
          };
        };

      users = {
        groups = {
          family.gid = familyGid;
          public.gid = 2003;
        };
        users =
          lib.mapAttrs (_: uid: {
            inherit uid;
            isSystemUser = true;
            group = "family";
            description = "NAS member (Samba only, no shell)";
          })
          members
          // {
            # Samba guest account; every session on `shared` writes as it.
            public = {
              uid = 2003;
              isSystemUser = true;
              group = "public";
              description = "Samba guest (no password)";
            };
            # Login for clients that refuse anonymous SMB (Windows): guest/guest.
            guest = {
              uid = 2004;
              isSystemUser = true;
              group = "public";
              description = "Samba visitor login (well-known password)";
            };
            # The arr/immich pods run as cloud; it should read the family shares.
            # incus-admin: drive Incus with `incus` without sudo.
            cloud.extraGroups = ["family" "incus-admin"];
          };
      };

      services = {
        resolved.enable = lib.mkForce false;

        zfs = {
          autoScrub = {
            enable = true;
            pools = ["rpool" "tank"]; # add "bulk" when it exists
            interval = "weekly";
          };
          trim.enable = true;
        };

        # Snapshots for everything that is not disposable. media is left out on
        # purpose; backup holds MinIO's own retention-managed dumps.
        sanoid = {
          enable = true;
          templates.default = {
            hourly = 24;
            daily = 14;
            monthly = 3;
            autosnap = true;
            autoprune = true;
          };
          datasets = let
            snap = {useTemplate = ["default"];};
            snapChildren =
              snap
              // {
                recursive = true;
                process_children_only = true;
              };
          in {
            "rpool/appdata" = snap;
            "rpool/db" = snapChildren;
            "tank/immich" = snap;
            "tank/shared" = snap;
            "tank/home" = snapChildren;
            "tank/photos" = snapChildren;
          };
        };

        # The SSD has no redundancy: replicate its snapshots to tank hourly, so
        # a dead SSD costs at most an hour of immich DB and app configs.
        syncoid = {
          enable = true;
          commonArgs = ["--no-sync-snap"];
          commands = {
            "rpool/db" = {
              target = "tank/replica/db";
              recursive = true;
            };
            "rpool/appdata".target = "tank/replica/appdata";
          };
        };

        smartd = {
          enable = true;
          autodetect = true;
          notifications.wall.enable = true;
        };

        # SMB for Windows Explorer, the iOS Files app and Android file managers.
        samba = {
          enable = true;
          openFirewall = true;
          settings =
            {
              global = {
                "server string" = "nas";
                security = "user";
                # Unknown usernames become the guest account; wrong passwords
                # for real users are still rejected.
                "map to guest" = "Bad User";
                "guest account" = "public";
                # Only list the shares the connecting user may open.
                "access based share enum" = "yes";
                # fruit must come first; it makes shares behave for Apple clients.
                "vfs objects" = "fruit streams_xattr";
                "fruit:metadata" = "stream";
                "fruit:nfs_aces" = "no";
                "fruit:veto_appledouble" = "no";
                "fruit:delete_empty_adfiles" = "yes";
                "inherit permissions" = "yes";
              };
              # The one folder for everyone: family logins, guest/guest, and
              # anonymous visitors. Every SMB session writes as `public`, so
              # anyone can tidy up after anyone; group family keeps rw for
              # local services and the pods.
              shared = {
                path = "/srv/nas/shared";
                "guest ok" = "yes";
                "read only" = "no";
                "force user" = "public";
                "force group" = "family";
                "create mask" = "0664";
                "directory mask" = "2775";
              };
              # Family photos nobody owns; an immich External Library as well.
              "photos-family-external" = familyShare "/srv/nas/photos/shared";
              # media is owned by cloud (uid 1000, what the arr pods run as).
              # Write as cloud so Sonarr/Radarr can still hardlink and clean up.
              media = {
                path = "/srv/nas/media";
                "valid users" = "@family";
                "read only" = "no";
                "force user" = "cloud";
                "force group" = "users";
              };
            }
            // lib.listToAttrs (lib.concatMap (u: [
                (lib.nameValuePair u {
                  path = "/srv/nas/home/${u}";
                  "valid users" = u;
                  "read only" = "no";
                })
                # Own photos: read/write here, and the same directory is an
                # immich External Library (mounted read-only in the pod).
                (lib.nameValuePair "photos-${u}-external" {
                  path = "/srv/nas/photos/${u}";
                  "valid users" = u;
                  "read only" = "no";
                })
                # immich's own library (phone backups), browsable but never
                # written to. Needs the storage template on and storage label = ${u}.
                (lib.nameValuePair "photos-${u}-immich-ro" {
                  path = "/srv/nas/immich/library/${u}";
                  "valid users" = u;
                  "read only" = "yes";
                })
              ])
              memberNames);
        };
        # Discovery: wsdd for Windows "Network"; avahi for nas.local and the
        # Finder sidebar on Macs/iPhones. nixpkgs' samba is built without mDNS,
        # so the SMB service is announced by a static avahi record instead.
        samba-wsdd = {
          enable = true;
          openFirewall = true;
        };
        avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
          publish = {
            enable = true;
            addresses = true;
            userServices = true;
          };
          extraServiceFiles.smb = ''
            <?xml version="1.0" standalone='no'?>
            <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
            <service-group>
              <name replace-wildcards="yes">%h</name>
              <service>
                <type>_smb._tcp</type>
                <port>445</port>
              </service>
              <!-- Finder icon: a rack server. -->
              <service>
                <type>_device-info._tcp</type>
                <port>0</port>
                <txt-record>model=RackMac</txt-record>
              </service>
            </service-group>
          '';
        };
      };

      # Dev containers (Rust apps, Telegram bots, ...):
      #   incus launch images:debian/13 bot -p default -p share
      #   incus exec bot -- bash
      #   incus delete -f bot
      # Re-applied on every incusd start, so nothing here may be "auto".
      virtualisation.incus.preseed = {
        networks = [
          {
            name = "incusbr0";
            type = "bridge";
            config = {
              # NAT to the LAN. 10.100.0.0/24 is dell's WireGuard subnet.
              "ipv4.address" = "10.20.0.1/24";
              "ipv4.nat" = "true";
              "ipv6.address" = "none";
            };
          }
        ];
        # Each instance is a ZFS dataset under rpool/incus (SSD), so launch,
        # snapshot and delete are instant. Incus creates the dataset itself.
        storage_pools = [
          {
            name = "default";
            driver = "zfs";
            config.source = "rpool/incus";
          }
        ];
        profiles = [
          {
            name = "default";
            # Nested namespaces get a clean procfs, which the Nix build
            # sandbox needs; the stock NixOS image cannot rebuild without it.
            config."security.nesting" = "true";
            devices = {
              eth0 = {
                name = "eth0";
                network = "incusbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                type = "disk";
              };
            };
          }
          # `-p share`: the SMB `shared` folder at /share. shift maps host uids
          # into the unprivileged container, so root inside reads and writes
          # everything. Files it creates are root:family 0644; use umask 002
          # (or chmod g+w) if they must stay editable over SMB.
          {
            name = "share";
            devices.share = {
              type = "disk";
              source = "/srv/nas/shared";
              path = "/share";
              shift = "true";
            };
          }
        ];
      };

      environment.systemPackages = with pkgs; [
        hdparm
        lm_sensors
        smartmontools
      ];

      systemd = {
        tpm2.enable = false;

        # Runs after local-fs.target, so these land inside the mounted datasets
        # and fix up ownership of each dataset root.
        tmpfiles.rules =
          [
            "d /srv/nas 0755 root root -"
            "d /srv/nas/appdata 0755 cloud users -"
            "d /srv/nas/db 0755 root root -"
            # immich's postgres image runs as uid/gid 999.
            "d /srv/nas/db/immich 0700 999 999 -"
            "d /srv/nas/immich 0755 cloud users -"
            "d /srv/nas/media 0755 cloud users -"
            "d /srv/nas/media/books 0755 cloud users -"
            "d /srv/nas/media/downloads 0755 cloud users -"
            "d /srv/nas/media/downloads/complete 0755 cloud users -"
            "d /srv/nas/media/downloads/incomplete 0755 cloud users -"
            "d /srv/nas/media/downloads/incomplete-nzb 0755 cloud users -"
            "d /srv/nas/media/movies 0755 cloud users -"
            "d /srv/nas/media/tv 0755 cloud users -"
            "d /srv/nas/backup 0755 cloud users -"
            "d /srv/nas/shared 2775 public family -"
            "d /srv/nas/home 0755 root root -"
            "d /srv/nas/photos 0755 root root -"
            "d /srv/nas/photos/shared 2775 root family -"
          ]
          ++ map (a: "d /srv/nas/appdata/${a} 0755 cloud users -") appdataDirs
          ++ lib.concatMap (u: [
            "d /srv/nas/home/${u} 0700 ${u} family -"
            "d /srv/nas/photos/${u} 0750 ${u} family -"
          ])
          memberNames;
      };

      powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    };
  };
}
