# Work MacBook — nix-darwin (user `smporyvaev`).
{mkDarwin, ...}: {
  flake.darwinConfigurations.mac = mkDarwin {
    aspects = m:
      with m; [
        common
        sudo
        xray
        brew
        tools
        mediatools
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
        "zenity"
      ];

      homebrew.casks = [
        "blender"
        "codex"
        "ghostty"
        "gimp"
        "moonlight"
        "obsidian"
        "openscad"
        "orcaslicer"
        "qbittorrent"
        "stolendata-mpv"
        "sweet-home3d"
        "telegram"
        "visual-studio-code"
        "zed"
        "zen"
        "zoom"
      ];
    };
  };
}
