# nix-index with the prebuilt, weekly-updated database (no manual indexing).
{inputs, ...}: {
  flake-file.inputs.nix-index-database = {
    url = "github:nix-community/nix-index-database";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.nix-index = {
    imports = [inputs.nix-index-database.homeModules.default];

    # command-not-found backed by the prebuilt db; `,` runs uninstalled tools.
    programs.nix-index.enable = true;
    programs.nix-index-database.comma.enable = true;
  };
}
