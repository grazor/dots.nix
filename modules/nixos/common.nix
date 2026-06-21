# Base configuration shared by every NixOS host.
{inputs, ...}: {
  flake.modules.nixos.common = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;

    nix = {
      registry.nixpkgs.flake = inputs.nixpkgs;
      settings = {
        experimental-features = "nix-command flakes";
        nix-path = ["nixpkgs=${inputs.nixpkgs.outPath}"];
        trusted-users = ["root" "@wheel"];
        # Keep dev-shell build deps across GC so direnv shells aren't rebuilt.
        keep-outputs = true;
        keep-derivations = true;
      };
    };

    boot = {
      loader = {
        systemd-boot.enable = true;
        systemd-boot.editor = false;
        timeout = 1;
        efi.canTouchEfiVariables = true;
      };
      tmp.cleanOnBoot = true;
    };

    services = {
      acpid.enable = true;
      pcscd.enable = true;
      dbus.packages = [pkgs.gcr];
      resolved.enable = true;
      resolved.settings.Resolve.FallbackDNS = ["8.8.8.8" "10.0.0.1"];
      logrotate.checkConfig = false;
    };

    # Detected hardware comes from nixos-facter per host; keep firmware on.
    hardware.enableRedistributableFirmware = true;

    networking.networkmanager.enable = true;
    networking.firewall.enable = false;
    systemd.services.NetworkManager-wait-online.enable = false;

    programs.fish.enable = true;
    users.defaultUserShell = pkgs.fish;

    environment.enableAllTerminfo = true;

    time.timeZone = "Europe/Moscow";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    environment.systemPackages = with pkgs; [
      direnv
      nh
      patchelf
      nix-inspect

      glibc.out
      acpi
      binutils
      brightnessctl
      ffmpeg
      findutils
      htop
      libnotify
      ntfs3g
      usbutils
      xdg-utils
      xdg-user-dirs
      nettools

      bind
      bridge-utils
      inetutils
      iw
      openvpn
    ];
  };
}
