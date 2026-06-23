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

        # Show each pane's title on its top border. `bin/project` writes a
        # `tmux select-pane -T <project>` line into the direnv .envrc, so the
        # border reads the project name whenever you're inside a dev shell.
        set-option -g pane-border-status top
        set-option -g pane-border-format " #{pane_index} #[bold]#{pane_title}#[default] "

        bind-key -n C-l if-shell "$is_vim" "send-keys C-l"  "send-keys C-l"

        bind _ split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
      '';
    };

    home.sessionVariables = {
      "TMUX_POWERLINE_LEFT_STATUS_SEGMENTS" = "tmux_session_info 148 234";
      "TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS" = "pwd 89 211";
      "TMUX_POWERLINE_STATUS_JUSTIFICATION" = "absolute-centre";
    };
  };
}
