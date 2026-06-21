# flake-file: inputs are declared in the module that uses them (via
# `flake-file.inputs.<name>`), and `flake.nix` is generated from them with
# `nix run .#write-flake`. The `dendritic` flakeModule wires the generated
# outputs to `mkFlake (import-tree ./modules)` — exactly this repo's layout —
# and declares the core inputs (flake-parts, import-tree, nixpkgs) with
# `mkDefault`, so overrides below and `systems` in args.nix win.
{inputs, ...}: {
  imports = [inputs.flake-file.flakeModules.dendritic];

  flake-file.inputs = {
    flake-file.url = "github:denful/flake-file";
    # Keep nixpkgs on the github ref already in flake.lock (the dendritic
    # default is the channels tarball, which would change the source + rebuild).
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  # Format the generated flake.nix with alejandra (the rest of the repo's style)
  # instead of the default nixfmt, so `nix fmt` (treefmt) leaves it untouched.
  flake-file.formatter = pkgs: pkgs.alejandra;
}
