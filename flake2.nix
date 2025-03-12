{
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  home-manager = {
    url = "github:rycee/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  nix-darwin = {
    url = "github:LnL7/nix-darwin/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
