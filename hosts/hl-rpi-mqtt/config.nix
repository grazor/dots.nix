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
      asServer = true;
      sshServer = true;
      withCommon = true;
      withWireless = true;
      withUserDefaults = true;
      withUdev = true;
    };

    withTools = true;
    withDevTools = true;
    withAuthorizedKeys = true;
    sshServer = true;
  };
}
