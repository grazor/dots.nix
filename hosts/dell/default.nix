{lib, ...}: {
  imports = [
    ./hardware.nix
    ./config.nix
  ];

  networking.hostName = "dell";
  system.stateVersion = "24.11";
  nix.settings.max-jobs = lib.mkDefault 8;

  environment.enableAllTerminfo = true;
  services.logrotate.checkConfig = false;

  networking.firewall.enable = false;
  services.resolved.enable = lib.mkForce false;
}
