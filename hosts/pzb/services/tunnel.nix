{ pkgs, ... }:

let
  description = "SSH tunnel";
in {
  systemd.services.tunnel = {
    description = description;

    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "exec";
      User = "cloud";
      Restart = "always";
      RestartSec = "1";
      ExecStart = "${pkgs.openssh}/bin/ssh -N -D 8999 tun@v.porivaev.ru";
    };
  };
}

