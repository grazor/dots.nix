# home-manager input. Consumed by mkNixos/mkDarwin in modules/flake/lib.nix.
{
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
