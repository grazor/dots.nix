{ config, pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      timeout = 1;
      efi.canTouchEfiVariables = true;
    };

    tmp.cleanOnBoot = true;
  };

  services.acpid.enable = true;
  services.sshd.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  powerManagement.enable = true;

  networking.networkmanager.enable = true;
  services.resolved.enable = true;
  services.resolved.fallbackDns = [ "8.8.8.8" "10.0.0.1" ];
  services.pptpd.enable = true;

  services.pcscd.enable = true;
  services.dbus.packages = [ pkgs.gcr ];

  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';
}

