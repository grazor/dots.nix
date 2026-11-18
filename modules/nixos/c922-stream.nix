# On-demand C922 RTSP stream for Frigate. Start/stop the service manually;
# go2rtc opens the webcam only while Frigate is reading it.
{
  flake.modules.nixos.webcamStream = {pkgs, ...}: let
    configFile = pkgs.writeText "c922-go2rtc.yaml" ''
      api:
        listen: "127.0.0.1:1984"
      rtsp:
        listen: ":8554"
      ffmpeg:
        bin: "${pkgs.ffmpeg}/bin/ffmpeg"
      streams:
        desktop_c922: "ffmpeg:device?video=0&video_size=1280x720&framerate=15#video=h264"
    '';
  in {
    systemd.services.c922-stream = {
      description = "Manual Logitech C922 stream for Frigate";
      after = ["network.target"];
      serviceConfig = {
        Type = "simple";
        User = "g";
        Group = "users";
        SupplementaryGroups = ["video"];
        ExecStart = "${pkgs.go2rtc}/bin/go2rtc -config ${configFile}";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };

    # Frigate runs on nas. Do not expose the unauthenticated RTSP stream to
    # the rest of the LAN or the internet.
    networking.firewall.extraCommands = ''
      iptables -I nixos-fw 1 -s 192.168.2.200/32 -p tcp --dport 8554 -j ACCEPT
    '';
    networking.firewall.extraStopCommands = ''
      iptables -D nixos-fw -s 192.168.2.200/32 -p tcp --dport 8554 -j ACCEPT || true
    '';
  };
}
