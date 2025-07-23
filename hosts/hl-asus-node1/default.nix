{lib, ...}: {
  imports = [
    ./hardware.nix
    ./config.nix
  ];

  networking.hostName = "minisrv";
  system.stateVersion = "25.05";
  nix.settings.max-jobs = lib.mkDefault 4;

  environment.enableAllTerminfo = true;
  services.logrotate.checkConfig = false;

  networking.firewall.enable = false;
  services.resolved.enable = lib.mkForce false;
}
