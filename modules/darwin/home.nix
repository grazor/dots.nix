# Work MacBook user (smporyvaev): account + home-manager profile.
{config, ...}: let
  hm = config.flake.modules.homeManager;
in {
  flake.modules.darwin.user-smporyvaev = {pkgs, ...}: {
    users.knownUsers = ["smporyvaev"];
    users.users.smporyvaev = {
      uid = 501;
      home = "/Users/smporyvaev";
      shell = pkgs.zsh;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.smporyvaev = {
        home.stateVersion = "25.05";
        imports = with hm; [zsh tmux tmux-autostart git scripts nvf yazi nix-index codex agent-dev kb-layout-sync imgsend karabiner];

        # The Mac uses the separately installed Codex binary.
        programs.codex.package = null;

        # Relay OSC 52 from an SSH session (including nested tmux) to Ghostty.
        programs.tmux.extraConfig = ''
          set-option -g set-clipboard on
        '';
      };
    };
  };
}
