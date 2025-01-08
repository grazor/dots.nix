{
  config,
  pkgs,
  inputs,
  ...
}:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      timeout = 1;
      efi.canTouchEfiVariables = true;
    };

    tmp.cleanOnBoot = true;
  };

  # We pin the system's nixpkgs to what we have in the Flake.
  # Both in the Flake registry, so nixpkgs resolves to our version by default
  # and when used with a command such as `nix run nixpkgs#hello`, but also
  # create a channel pointing to the same version.
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=/etc/channels/nixpkgs" ];
  environment.etc."channels/nixpkgs".source = inputs.nixpkgs.outPath;

  services.acpid.enable = true;
  services.sshd.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  networking.networkmanager.enable = true;
  services.resolved.enable = true;
  services.resolved.fallbackDns = [
    "8.8.8.8"
    "10.0.0.1"
  ];
  #services.pptpd.enable = true;

  services.pcscd.enable = true;
  services.dbus.packages = [ pkgs.gcr ];

  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';
}
