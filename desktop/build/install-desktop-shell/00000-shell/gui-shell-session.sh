#! /bin/bash
set -euo pipefail

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-agent}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export DISPLAY="${DISPLAY:-:0}"
export HOME="$(getent passwd "${SESSION_USER:-agent}" | cut -d: -f6)"

# Everything here is a layer-shell client of labwc, so it has to come after the
# compositor is up.
for _ in $(seq 1 120); do
  [ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ] && break
  sleep 0.5
done
[ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ] || exit 1

# Background. Unlike niri, labwc composites the layer-shell background surface,
# so a plain colour via swaybg is all that is needed (no wallpaper image).
swaybg -c "#222731" >/dev/null 2>&1 &
sleep 0.5

# Keep the desktop search indexer off $HOME. The home directory here is a data
# volume measured in gigabytes, and the miner walking it is what makes the
# first Nautilus launch take ages. File browsing and the rest of Nautilus work
# without the index; only full-text search loses content it was never asked to
# scan. Re-applied every session because the mount hides anything baked into
# the image.
gsettings set org.freedesktop.Tracker3.Miner.Files index-recursive-directories "[]" >/dev/null 2>&1 || true
gsettings set org.freedesktop.Tracker3.Miner.Files index-single-directories "[]" >/dev/null 2>&1 || true

# Clipboard history: every new selection lands in cliphist's database, which the
# picker script reads back. Runs for the whole session.
wl-paste --watch cliphist store >/dev/null 2>&1 &

# The bar stays in the foreground; if it dies the wrapper restarts and brings
# the background pieces with it. A desktop without a bar is not usable.
exec waybar -c /etc/xdg/waybar/config.jsonc -s /etc/xdg/waybar/style.css
