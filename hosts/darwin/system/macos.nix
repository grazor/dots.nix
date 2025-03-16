_: {
  system.defaults = {
    dock = {
      autohide = true;
      mru-spaces = false;
      orientation = "left";
    };
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    screencapture.location = "~/Pictures/screenshots";
  };

  security.pam.services.sudo_local.touchIdAuth = true;
}
