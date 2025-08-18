{pkgs, ...}: {
  nix.enable = false;
  system.stateVersion = 6;
  system.primaryUser = "smporyvaev";

  grazor = {
    user = rec {
      uid = 501;
      name = "smporyvaev";
      gid = 20;
      group = "staff";
      home = "/Users/${name}";
      shell = pkgs.fish;

      config = {
        withGit = true;
        withTmux = true;
        shellInitTmux = true;
        withFish = true;
        withGhostty = false;
        withScripts = true;
      };
    };

    darwin = {
      withCommon = true;
      withSudo = true;
      withBrew = true;
    };

    withTools = true;
    withDevtools = true;
    withNvf = true;
    withFonts = true;
    withAuthorizedKeys = true;
    sshServer = true;
  };

  homebrew = {
    brews = ["syncthing"];
    casks = ["obsidian"];
  };
}
