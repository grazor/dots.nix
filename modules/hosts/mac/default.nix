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
        stylix
        user-smporyvaev
        agent-dev
      ];

    machine = {
      nix.enable = false;
      system.stateVersion = 6;
      system.primaryUser = "smporyvaev";

      homebrew.brews = [
        "cabextract"
        {
          name = "docker";
          link = false;
        }
        "docker-buildx"
        "docker-compose"
        "docker-credential-helper"
        "git-lfs"
        "graphviz"
        "htop"
        "kanata"
        "mpv"
        "qemu"
        "sevenzip"
        "wireguard-tools"
        "xray"
        "zenity"
      ];

      homebrew.casks = [
        "blender"
        "codex"
        "ghostty"
        "gimp"
        "obsidian"
        "openscad"
        "orcaslicer"
        "qbittorrent"
        "stolendata-mpv"
        "sweet-home3d"
        "visual-studio-code"
        "zed"
        "zen"
        "zoom"
      ];
    };
  };
}
