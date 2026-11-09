{
  flake.modules.homeManager.tmux = {pkgs, ...}: {
    programs.zsh.initContent = ''
      source ${./data/tmux-ssh.zsh}
    '';

    programs.tmux = {
      enable = true;
      # Existing servers may have inherited fish through $SHELL.
      shell = "${pkgs.zsh}/bin/zsh";
      # The default "screen" advertises only eight colors to shells and apps.
      terminal = "tmux-256color";
      keyMode = "vi";
      baseIndex = 1;
      clock24 = true;
      mouse = true;

      plugins = with pkgs; [
        tmuxPlugins.tmux-powerline
        tmuxPlugins.yank
        tmuxPlugins.open
        tmuxPlugins.fingers
        tmuxPlugins.tmux-floax
      ];

      extraConfig = ''
        set-option -g renumber-windows on
        set-option -g focus-events on

        # Pass OSC 8 hyperlinks through to the outer terminal (Ghostty reports
        # TERM=xterm-ghostty). tmux strips them unless the feature is declared.
        set-option -as terminal-features ",xterm*:hyperlinks"

        # Keep pane borders compact; project names are shown in the tmux window
        # list via the direnv hook in modules/home/zsh.nix.
        set-option -g pane-border-status off

        # Let a nested tmux (usually reached over SSH) own the keyboard and
        # mouse until C-] is pressed again. The prefix stays C-b on both hosts.
        bind -T root C-] \
          set-option prefix None \; \
          set-option key-table nested \; \
          set-option mouse off \; \
          set-option status off
        bind -T nested C-] \
          set-option -u prefix \; \
          set-option -u key-table \; \
          set-option -u mouse \; \
          set-option -u status

        bind _ split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind C-c new-session
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        bind f resize-pane -Z
        bind -r H resize-pane -L 5
        bind -r J resize-pane -D 5
        bind -r K resize-pane -U 5
        bind -r L resize-pane -R 5
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

      # Status segments, each "<segment> <bg> <fg>" with 256-colour indices.
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
