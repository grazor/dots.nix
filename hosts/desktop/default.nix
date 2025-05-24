{lib, ...}: {
  imports = [
    ./hardware.nix
    ./config.nix
  ];

  networking.hostName = "desktop";
  system.stateVersion = "25.05";
  nix.settings.max-jobs = lib.mkDefault 8;

  environment.enableAllTerminfo = true;
  services.logrotate.checkConfig = false;

  networking.firewall.enable = false;
}
