#! /bin/bash
# Region screenshot: slurp picks the area, grim grabs it, wl-copy puts it on the
# clipboard so it can be pasted straight into a chat window.
set -euo pipefail

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-agent}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"

dir="${HOME:-/mnt/workspace}/Pictures"
mkdir -p "$dir"

geom="$(slurp)" || exit 0
[ -n "$geom" ] || exit 0

file="$dir/screenshot-$(date +%Y%m%d-%H%M%S).png"
grim -g "$geom" "$file"

wl-copy < "$file" || true
notify-send -a screenshot 'Screenshot saved' "$file" || true
