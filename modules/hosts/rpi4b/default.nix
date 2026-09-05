# Raspberry Pi 4B — native Zigbee2MQTT bridge to the k3s MQTT broker.
{mkNixos, ...}: {
  flake.nixosConfigurations.rpi4b = mkNixos {
    system = "aarch64-linux";
    aspects = m:
      with m; [
        common
        raspberry-pi-4
        headless
        ssh-server
        sops
        zigbee2mqtt-native
        user-pi
      ];

    machine = {
      lib,
      pkgs,
      ...
    }: {
      networking = {
        hostName = "rpi4b";

        # The MetalLB pools sit behind the k3s server, which shares this L2
        # segment. Routing them via the gateway makes the router hairpin
        # traffic back out the interface it arrived on, and it drops that — so
        # point them straight at the k3s node instead.
        #
        # Declared twice on purpose: facter puts end0 under scripted networking,
        # so network-setup.service installs these at boot; NetworkManager also
        # manages the link and flushes foreign routes when it reconfigures it,
        # so the dispatcher reinstates them on link-up. `ip route replace` is
        # idempotent, which makes the pair safe.
        interfaces.end0.ipv4.routes = [
          {
            address = "192.168.10.0";
            prefixLength = 24;
            via = "192.168.2.2";
          }
          {
            address = "192.168.11.0";
            prefixLength = 24;
            via = "192.168.2.2";
          }
        ];

        networkmanager.dispatcherScripts = [
          {
            type = "basic";
            source = pkgs.writeShellScript "homelab-routes" ''
              interface="$1"
              action="$2"
              [ "$interface" = "end0" ] || exit 0
              case "$action" in
                up | dhcp4-change)
                  ${pkgs.iproute2}/bin/ip route replace 192.168.10.0/24 via 192.168.2.2 dev end0
                  ${pkgs.iproute2}/bin/ip route replace 192.168.11.0/24 via 192.168.2.2 dev end0
                  ;;
              esac
            '';
          }
        ];
      };
      system.stateVersion = "25.05";
      nix.settings.max-jobs = lib.mkDefault 2;

      systemd.tpm2.enable = false;
      services = {
        acpid.enable = lib.mkForce false;
        pcscd.enable = lib.mkForce false;

        # The cluster's Prometheus scrapes this host by address - the Pi is
        # not a k8s node, so there is no endpoint to discover. systemd gives
        # the zigbee2mqtt unit's state; thermal_zone gives the SoC
        # temperature, which is the number that actually matters on a Pi.
        prometheus.exporters.node = {
          enable = true;
          listenAddress = "0.0.0.0";
          port = 9100;
          enabledCollectors = ["systemd" "thermal_zone"];
          openFirewall = true;
        };
      };

      # Regenerate on the device:
      #   sudo nixos-facter -o modules/hosts/rpi4b/facter.json
      facter.reportPath = ./facter.json;

      # Replace this UUID after preparing the SD card / USB SSD. With the
      # standard NixOS aarch64 SD-card layout, extlinux lives in /boot on the
      # root filesystem and Raspberry Pi firmware lives on /boot/firmware.
      fileSystems."/" = {
        device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
        fsType = "ext4";
      };
      fileSystems."/boot/firmware" = {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
        options = ["nofail" "noauto"];
      };

      # No `tools`/`devtools` here. This host runs one service, and those
      # aspects carry a workstation's worth of things it has no use for -
      # k9s, fluxcd, jira-cli, postgresql, glow, tig, shellcheck, shfmt,
      # gnumake, python3 - on an SD card. What is left is what is actually
      # used to look after it: an editor, git to pull this repo, and enough
      # to poke at the broker. `common` already provides the network and
      # hardware tooling (bind, iproute2, iw, usbutils, htop, ...).
      environment.systemPackages = with pkgs; [
        vim
        git
        curl
        jq
        ncdu
      ];

      powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    };
  };
}
