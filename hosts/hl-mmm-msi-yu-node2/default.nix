{lib, ...}: {
  imports = [
    ./hardware.nix
    ./config.nix

    ./purpose-node.nix
  ];

  networking.hostName = "hl-mmm-msi-yu-node2";
  system.stateVersion = "25.05";
  nix.settings.max-jobs = lib.mkDefault 8;

  environment.enableAllTerminfo = true;
  services.logrotate.checkConfig = false;

  networking.firewall.enable = false;
  services.resolved.enable = lib.mkForce false;
}
