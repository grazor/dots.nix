{...}: {
  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    dock.orientation = "left";
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    screencapture.location = "~/Pictures/screenshots";
  };

  programs = {
    direnv.enable = true;
    tmux.enable = true;
  };

  security.pam.services.sudo_local.touchIdAuth = true;
}
