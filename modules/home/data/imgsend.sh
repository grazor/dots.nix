#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || $1 == -h || $1 == --help || $1 == -* ]]; then
  printf 'Usage: imgsend SSH_ALIAS\n' >&2
  exit 2
fi

target=$1
temporary=$(mktemp -d "${TMPDIR:-/tmp}/imgsend.XXXXXXXX")
trap 'rm -rf "$temporary"' EXIT

extension=
image=
case $(uname -s) in
Darwin)
  extension=png
  image="$temporary/image.png"
  pngpaste "$image" || {
    printf 'imgsend: no image in the Mac clipboard\n' >&2
    exit 1
  }
  ;;
Linux)
  if [[ -z ${WAYLAND_DISPLAY:-} ]]; then
    printf 'imgsend: a Wayland session is required on Linux\n' >&2
    exit 1
  fi
  offered=$(wl-paste --list-types)
  for mime in image/png image/jpeg image/webp image/gif image/tiff image/bmp; do
    if printf '%s\n' "$offered" | grep -Fxq "$mime"; then
      case $mime in
      image/png) extension=png ;;
      image/jpeg) extension=jpg ;;
      image/webp) extension=webp ;;
      image/gif) extension=gif ;;
      image/tiff) extension=tiff ;;
      image/bmp) extension=bmp ;;
      esac
      image="$temporary/image.$extension"
      wl-paste --type "$mime" >"$image"
      break
    fi
  done
  if [[ -z $image ]]; then
    printf 'imgsend: no supported image in the Wayland clipboard\n' >&2
    exit 1
  fi
  ;;
*)
  printf 'imgsend: macOS and Linux Wayland are supported\n' >&2
  exit 1
  ;;
esac

if [[ ! -s $image ]]; then
  printf 'imgsend: clipboard image is empty\n' >&2
  exit 1
fi

# The extension comes only from the fixed MIME list above. SSH uses the alias
# and identity from the caller's configuration; no remote shell input is taken
# from the clipboard or from the SSH alias.
# shellcheck disable=SC2016
remote_command='set -eu
umask 077
directory=$(mktemp -d /tmp/imgsend.XXXXXXXX)
image="$directory/image.'$extension'"
if cat > "$image"; then
  printf "%s\n" "$image"
else
  rm -rf "$directory"
  exit 1
fi'

if ! remote_path=$(ssh -T -o BatchMode=yes -- "$target" "$remote_command" <"$image"); then
  printf 'imgsend: upload to %s failed\n' "$target" >&2
  exit 1
fi
if [[ $remote_path != /tmp/imgsend.*/image."$extension" || $remote_path == *$'\n'* ]]; then
  printf 'imgsend: remote host returned an unexpected path\n' >&2
  exit 1
fi

case $(uname -s) in
Darwin) printf '%s' "$remote_path" | pbcopy ;;
Linux) printf '%s' "$remote_path" | wl-copy --type text/plain ;;
esac
printf '%s\n' "$remote_path"
