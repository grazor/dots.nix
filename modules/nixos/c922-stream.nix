# On-demand C922 publisher for Frigate. Start/stop the service manually.
{
  flake.modules.nixos.webcamStream = {
    pkgs,
    config,
    ...
  }: let
    publish = pkgs.writeShellScript "c922-publish" ''
      set -eu
      password=$(${pkgs.coreutils}/bin/cat "$CREDENTIALS_DIRECTORY/rtsp-password")
      exec ${pkgs.ffmpeg}/bin/ffmpeg -hide_banner -loglevel warning \
        -f v4l2 -framerate 15 -video_size 1280x720 -i /dev/video0 \
        -c:v libx264 -g 50 -profile:v high -level:v 4.1 \
        -preset:v superfast -tune:v zerolatency -pix_fmt:v yuv420p -an \
        -rtsp_transport tcp -f rtsp \
        "rtsp://desktop_c922:''${password}@192.168.2.200:30554/desktop_c922"
    '';
  in {
    sops.secrets.c922-rtsp-password = {
      sopsFile = ../../secrets/c922.yaml;
      key = "rtsp-password";
    };

    systemd.services.c922-stream = {
      description = "Manual Logitech C922 publisher for Frigate";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        Type = "simple";
        User = "g";
        Group = "users";
        SupplementaryGroups = ["video"];
        LoadCredential = "rtsp-password:${config.sops.secrets.c922-rtsp-password.path}";
        ExecStart = publish;
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
