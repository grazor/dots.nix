{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    baseIndex = 1;
    clock24 = true;
    mouse = true;

    plugins = with pkgs; [
      tmuxPlugins.tmux-powerline
      tmuxPlugins.yank
    ];

    extraConfig = ''
      bind-key -n C-l if-shell "$is_vim" "send-keys C-l"  "send-keys C-l"

      bind _ split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';
  };
}
