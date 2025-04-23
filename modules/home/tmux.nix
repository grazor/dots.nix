{
  lib,
  config,
  pkgs,
  ...
}: let
  username = config.grazor.user.name;
  cfg = config.grazor.user.config;
in {
  options.grazor.user.config.withTmux = lib.mkEnableOption "with tmux";
  options.grazor.user.config.shellInitTmux = lib.mkEnableOption "run tmux on init";

  config = lib.mkIf cfg.withTmux {
    home-manager.users.${username}.programs.tmux = {
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

        bind-key -n C-l if-shell "$is_vim" "send-keys C-l"  "send-keys C-l"

        bind _ split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
      '';
    };
  };
}
