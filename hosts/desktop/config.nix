{pkgs, ...}: {
  grazor = {
    user = rec {
      uid = 1000;
      name = "g";
      gid = 100;
      group = "users";
      home = "/home/${name}";
      shell = pkgs.fish;

      config = {
        withGit = true;
        withTmux = true;
        shellInitTmux = true;
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
      withSteam = true;
      asServer = false;

      withNvidia = true;
      withIntel = true;

      withHyprland = false;
      withGnome = true;
      withGuiApps = true;
    };

    withTools = true;
    withDevtools = true;
    withNvf = true;
    withFonts = true;
    withAuthorizedKeys = true;
    sshServer = true;
  };
}
