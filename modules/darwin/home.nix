# Work MacBook user (smporyvaev): account + home-manager profile.
{config, ...}: let
  hm = config.flake.modules.homeManager;
in {
  flake.modules.darwin.user-smporyvaev = {pkgs, ...}: {
    users.knownUsers = ["smporyvaev"];
    users.users.smporyvaev = {
      uid = 501;
      home = "/Users/smporyvaev";
      shell = pkgs.fish;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.smporyvaev = {
        home.stateVersion = "25.05";
        imports = with hm; [fish tmux tmux-autostart git scripts nvf yazi nix-index agent-dev kb-layout-sync imgsend];

        # Merge TUI usage indicators into the existing Mac Codex config while
        # keeping the Mac's separately installed Codex binary.
        programs.codex = {
          enable = true;
          package = null;
          mutableSettings = true;
          settings.tui.status_line = [
            "context-remaining"
            "used-tokens"
            "five-hour-limit"
            "weekly-limit"
          ];
        };

        # Relay OSC 52 from an SSH session (including nested tmux) to Ghostty.
        programs.tmux.extraConfig = ''
          set-option -g set-clipboard on
        '';
      };
    };
  };
}
