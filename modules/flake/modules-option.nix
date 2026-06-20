# Declares the `flake.modules.<class>.<name>` output used by the dendritic
# pattern: a two-level attrset of deferred modules that merge across files.
{
  lib,
  flake-parts-lib,
  ...
}: {
  options.flake = flake-parts-lib.mkSubmoduleOptions {
    modules = lib.mkOption {
      type = with lib.types; lazyAttrsOf (lazyAttrsOf deferredModule);
      default = {};
      description = "Dendritic aspect modules, keyed by class (nixos/darwin/homeManager) then aspect name.";
    };
  };
}
