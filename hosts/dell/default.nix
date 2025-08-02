{lib, ...}: {
  imports = [
    ./hardware.nix
    ./config.nix

    #./purpose-laptop.nix
    ./purpose-node.nix
  ];

  networking.hostName = "dell";
  system.stateVersion = "25.05";
  nix.settings.max-jobs = lib.mkDefault 8;

  environment.enableAllTerminfo = true;
  services.logrotate.checkConfig = false;

  networking.firewall.enable = false;
  services.resolved.enable = lib.mkForce false;
}
