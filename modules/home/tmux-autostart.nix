# Start/attach a tmux session automatically on interactive login.
{
  flake.modules.homeManager.tmux-autostart = {
    programs.fish.loginShellInit = ''
      [ -z "$TMUX" ] && tmux new-session -A -s main
    '';
  };
}
