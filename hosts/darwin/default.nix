{pkgs, ...}: {
  imports = [
    ./brew.nix
  ];

  # core
  nix.enable = false;
  nix.settings.experimental-features = "nix-command flakes";
  system.stateVersion = 6;

  # macos
  system.defaults = {
    dock = {
      autohide = true;
      mru-spaces = false;
      orientation = "right";
    };
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    screencapture.location = "~/Pictures/screenshots";
  };

  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

  services.openssh.enable = true;

  # graz
  programs.fish.enable = true;
  grazor = {
    user = rec {
      uid = 501;
      name = "smporybaev";
      home = "/Users/${name}";
      shell = pkgs.fish;

      config = {
        withGit = true;
        withTmux = true;
        shellInitTmux = true;
        withFish = true;
        withGhostty = true;
        withScripts = true;
      };
    };
    withTools = true;
    withDevtools = true;
    withFonts = true;
    withAuthorizedKeys = true;
  };
}
