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

      asServer = false;
      withBatterySave = false;
      k3sServer = true;

      withGuiApps = true;
      withGnome = true;
      withHyprland = false;
      withSteam = true;

      withNvidia = false;
      withIntel = true;
    };

    services = {
      ollama.enable = false;
      xray.enable = true;
    };

    withTools = true;
    withDevtools = true;
    withNvf = true;
    withFonts = true;
    withAuthorizedKeys = true;
    sshServer = true;
  };
}
