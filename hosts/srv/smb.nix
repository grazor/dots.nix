{ lib, ... }:

{
  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  networking.firewall.allowedTCPPorts = [
    5357 # wsdd
  ];
  networking.firewall.allowedUDPPorts = [
    3702 # wsdd
  ];

  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = pvserv
      netbios name = pvserv
      security = user 
      #use sendfile = yes
      #max protocol = smb2
      hosts allow = 192.168.1. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user

      wins support = yes
      local master = yes
      preferred master = yes
    '';

    shares = {
      public = {
        #path = "/share/Public";
        path = "/home/tmp";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "smball";
        "force group" = "smb";
      };
    };
  };
}
