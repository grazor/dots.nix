# Work MacBook — nix-darwin (user `smporyvaev`).
{mkDarwin, ...}: {
  flake.darwinConfigurations.mac = mkDarwin {
    aspects = m:
      with m; [
        common
        sudo
        brew
        tools
        devtools
        fonts
        user-smporyvaev
      ];

    machine = {
      nix.enable = false;
      system.stateVersion = 6;
      system.primaryUser = "smporyvaev";

      homebrew.brews = ["syncthing"];
      homebrew.casks = ["obsidian"];
    };
  };
}
