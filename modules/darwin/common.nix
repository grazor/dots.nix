# Base nix-darwin system defaults.
{
  flake-file.inputs.nix-darwin = {
    url = "github:nix-darwin/nix-darwin/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.darwin.common = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;

    programs.fish.enable = true;

    environment.systemPackages = [pkgs.nh];

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
