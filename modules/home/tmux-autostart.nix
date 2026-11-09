# Start/attach a tmux session automatically on interactive login.
{
  flake.modules.homeManager.tmux-autostart = {
    programs.zsh.loginExtra = ''
      if [[ -o interactive && -z "$TMUX" ]]; then
        tmux new-session -A -s main
      fi
    '';
  };
}
