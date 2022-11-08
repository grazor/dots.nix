{ ... }:

{
  networking.firewall.enable = false;

  services.resolved.extraConfig = ''
    DNSStubListener=No
  '';
}
