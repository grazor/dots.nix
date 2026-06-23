{
  flake.modules.homeManager.tmux = {pkgs, ...}: {
    programs.tmux = {
      enable = true;
      keyMode = "vi";
      baseIndex = 1;
      clock24 = true;
      mouse = true;

      plugins = with pkgs; [
        tmuxPlugins.tmux-powerline
        tmuxPlugins.yank
        tmuxPlugins.tmux-floax
      ];

      extraConfig = ''
        set-option -g renumber-windows on

        # Keep pane borders compact; project names are shown in the tmux window
        # list via the direnv hook in modules/home/fish.nix.
        set-option -g pane-border-status off

        bind-key -n C-l if-shell "$is_vim" "send-keys C-l"  "send-keys C-l"

        bind _ split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
      '';
    };

    # tmux-powerline reads this on startup (it sources $XDG_CONFIG_HOME/
    # tmux-powerline/config.sh before applying its own defaults). Managing it
    # here keeps the status bar declarative — previously these lived in env
    # vars, but the plugin's auto-generated config.sh shadowed them and forced
    # status-justify back to "centre". Only settings that differ from the
    # plugin defaults are pinned; the rest fall back to its config/defaults.sh.
    xdg.configFile."tmux-powerline/config.sh".text = ''
      # Pin the window list to the true centre of the bar (needs tmux >= 3.2).
      export TMUX_POWERLINE_STATUS_JUSTIFICATION="absolute-centre"

      # Status segments, each "<segment> <fg> <bg>" with 256-colour indices.
      # Overrides the default theme's richer segment set.
      TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
        "tmux_session_info 148 234"
      )
      TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
        "pwd 89 211"
      )
    '';
  };
}
