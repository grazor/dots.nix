{pkgs, ...}: {
  grazor = {
    user = rec {
      uid = 1000;
      name = "cloud";
      gid = 100;
      group = "users";
      home = "/home/${name}";
      shell = pkgs.fish;

      config = {
        withGit = true;
        withTmux = true;
        shellInitTmux = false;
        withFish = true;
        withScripts = true;
      };
    };

    linux = {
      withCommon = true;
      withWireless = true;
      withDocker = true;
      withUserDefaults = true;
      withUdev = true;
      withPipewire = true;
      withProxy = true;

      withNvidia = false;
      withIntel = true;

      wireguardServer = {
        enable = true;
        # Forward this UDP port on the router to this host.
        listenPort = 51820;
        peers = [
          # Add a client per device, e.g.:
          # {
          #   publicKey = "<client public key>";
          #   allowedIPs = ["10.100.0.2/32"];
          # }
        ];
      };
    };

    withTools = true;
    withDevtools = true;
    withNvf = true;
    withFonts = true;
    withAuthorizedKeys = true;
    sshServer = true;
  };
}
