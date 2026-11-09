# Forward the outer tmux while a foreground SSH command owns the terminal.
# `command ssh` bypasses this interactive-shell helper when needed.
function ssh() {
  local tmux_ssh_session tmux_ssh_option
  local -A tmux_ssh_saved

  if [[ -z $TMUX || -z $TMUX_PANE || ! -t 0 || ! -t 1 ]] ||
    ! tmux_ssh_session=$(command tmux display-message -p -t "$TMUX_PANE" '#{session_id}' 2>/dev/null); then
    command ssh "$@"
    return
  fi

  # An empty local value means the option was inherited. Preserve that too.
  for tmux_ssh_option in prefix key-table mouse status; do
    tmux_ssh_saved[$tmux_ssh_option]=$(command tmux show-options -qv -t "$tmux_ssh_session" "$tmux_ssh_option" 2>/dev/null) || {
      command ssh "$@"
      return
    }
  done

  {
    command tmux set-option -t "$tmux_ssh_session" prefix None \; \
      set-option -t "$tmux_ssh_session" key-table nested \; \
      set-option -t "$tmux_ssh_session" mouse off \; \
      set-option -t "$tmux_ssh_session" status off 2>/dev/null
    command ssh "$@"
  } always {
    # Restore the snapshot, never toggle: manual C-] presses are harmless.
    # zsh's always block also runs on interruption and preserves SSH's status.
    for tmux_ssh_option in prefix key-table mouse status; do
      if [[ -n ${tmux_ssh_saved[$tmux_ssh_option]} ]]; then
        command tmux set-option -t "$tmux_ssh_session" "$tmux_ssh_option" "${tmux_ssh_saved[$tmux_ssh_option]}"
      else
        command tmux set-option -u -t "$tmux_ssh_session" "$tmux_ssh_option"
      fi
    done 2>/dev/null
  }
}
