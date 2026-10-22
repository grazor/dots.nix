# Homebrew integration. Packages/casks are declared per-host (see hosts/mac).
{
  flake.modules.darwin.brew = {
    homebrew = {
      enable = true;
      onActivation = {
        cleanup = "none"; # keep brew packages not declared here
        # Install what is missing, leave already-installed versions alone.
        autoUpdate = false;
        upgrade = false;
      };
    };
  };
}
