set -euo pipefail

if [[ $# -lt 1 || $1 == -h || $1 == --help ]]; then
  printf 'Usage: codex-remote SSH_TARGET [CODEX_OPTIONS...]\n' >&2
  printf 'Example: codex-remote dev -C /remote/project\n' >&2
  exit 2
fi

target=$1
shift

if ! command -v codex >/dev/null 2>&1; then
  printf 'codex-remote: install Codex on this Mac first\n' >&2
  exit 1
fi

# Start the per-user server, then wait for its socket before opening the tunnel.
remote_uid=$(ssh "$target" '
  systemctl --user start codex-remote.service || exit
  uid=$(id -u)
  socket="/run/user/$uid/codex-remote.sock"
  attempt=0
  while [ "$attempt" -lt 50 ]; do
    if [ -S "$socket" ]; then
      printf "%s\n" "$uid"
      exit 0
    fi
    attempt=$((attempt + 1))
    sleep 0.1
  done
  printf "codex-remote: remote app server socket was not ready\n" >&2
  exit 1
')
if [[ ! $remote_uid =~ ^[0-9]+$ ]]; then
  printf 'codex-remote: could not determine the remote user ID\n' >&2
  exit 1
fi
remote_socket="/run/user/$remote_uid/codex-remote.sock"

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/codex-remote.XXXXXXXX")
local_socket="$tmp_dir/app.sock"
tunnel_pid=
cleanup() {
  if [[ -n $tunnel_pid ]]; then
    kill "$tunnel_pid" 2>/dev/null || true
    wait "$tunnel_pid" 2>/dev/null || true
  fi
  rm -rf "$tmp_dir"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

ssh -N -o BatchMode=yes -o ExitOnForwardFailure=yes \
  -L "$local_socket:$remote_socket" "$target" &
tunnel_pid=$!

for ((attempt = 0; attempt < 50; attempt++)); do
  if [[ -S $local_socket ]]; then
    codex --remote "unix://$local_socket" "$@"
    exit $?
  fi
  if ! kill -0 "$tunnel_pid" 2>/dev/null; then
    printf 'codex-remote: SSH tunnel exited before the socket was ready\n' >&2
    exit 1
  fi
  sleep 0.1
done

printf 'codex-remote: timed out waiting for the SSH socket\n' >&2
exit 1
