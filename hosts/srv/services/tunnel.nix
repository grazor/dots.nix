{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [ tun2socks ];

  systemd.services.tunnel = {
    description = "SSH tunnel";

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

  systemd.services.socks = {
    description = "Tunnel network interface";

    wantedBy = [ "multi-user.target" ];
    requires = [ "tunnel.service" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "exec";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.tun2socks}/bin/tun2socks -device socks0 -proxy socks5://127.0.0.1:8999";
      ExecStartPost = "+" + pkgs.writeShellScript "wrap-traffic" ''
set -e
PATH=/run/current-system/sw/bin

hosts=$(cat <<EOF
    tracker.opentrackr.org
    tracker.zer0day.to    
    tracker.coppersurfer.tk
    tracker.leechers-paradise.org
    tracker.internetwarriors.net
    mgtracker.org 
EOF
)

ip addr add 127.254.254.1/32 dev socks0
ip link set socks0 up

ips=$(echo "$hosts" | xargs getent hosts | cut -d' ' -f1)
echo "$ips" | while read ip
do
    ip route add $ip/32 dev socks0
done
      '';
    };
  };
}

