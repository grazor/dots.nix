# Homebrew integration. Packages/casks are declared per-host (see hosts/mac).
{
  flake.modules.darwin.brew = {
    homebrew = {
      enable = true;
      onActivation = {
        cleanup = "none";
        autoUpdate = true;
        upgrade = true;
      };
    };
  };
}
