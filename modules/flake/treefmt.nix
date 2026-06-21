# treefmt-nix: repo formatter, exposed as `nix fmt` and `formatter.<system>`.
{inputs, ...}: {
  flake-file.inputs.treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [inputs.treefmt-nix.flakeModule];

  perSystem.treefmt = {
    projectRootFile = "flake.nix";
    # alejandra matches the repo's existing `{pkgs, ...}:` formatting, and the
    # generated flake.nix is alejandra-formatted too (see flake-file.nix), so a
    # `nix fmt` run produces no diff against `nix run .#write-flake`.
    programs.alejandra.enable = true;
  };
}
