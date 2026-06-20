# Base nix-darwin system defaults.
{
  flake.modules.darwin.common = {
    nixpkgs.config.allowUnfree = true;

    programs.fish.enable = true;

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
  };
}
