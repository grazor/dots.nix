{ lib, ... }:

{
  imports = [ ./hardware.nix ./smb.nix ./zfs.nix ];

  networking.firewall.enable = false;

  services.resolved.extraConfig = ''
    DNSStubListener=No
  '';

  nix.settings.max-jobs = lib.mkDefault 4;
}

