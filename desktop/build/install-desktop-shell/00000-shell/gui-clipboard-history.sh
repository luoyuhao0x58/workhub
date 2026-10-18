#! /bin/bash
# Pick an entry from cliphist and put it back on the clipboard.
set -euo pipefail

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-agent}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"

entry="$(cliphist list | fuzzel --dmenu --prompt 'Clipboard: ' --lines 12)" || exit 0
[ -n "$entry" ] || exit 0

printf '%s' "$entry" | cliphist decode | wl-copy
