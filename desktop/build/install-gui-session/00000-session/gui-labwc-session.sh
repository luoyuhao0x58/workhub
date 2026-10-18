#! /bin/bash
set -euo pipefail

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-agent}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export DISPLAY="${DISPLAY:-:0}"
export XDG_CURRENT_DESKTOP=labwc
export XDG_SESSION_TYPE=wayland

# the audio stack must be up first: labwc's client apps expect a working sink
for _ in $(seq 1 120); do
  [ -S "$XDG_RUNTIME_DIR/pipewire-0" ] && break
  sleep 0.5
done
[ -S "$XDG_RUNTIME_DIR/pipewire-0" ] || exit 1

# Drop sockets left by a previous run. wlroots' XWayland picks the lowest free
# display number, so a stale socket would push the session to :1 while apps
# keep targeting the documented DISPLAY=:0.
rm -f /tmp/.X11-unix/X* /tmp/.X*-lock

# no GPU by default: headless backend with software rendering
exec env WLR_BACKENDS="${WLR_BACKENDS:-headless}" \
         WLR_RENDERER="${WLR_RENDERER:-pixman}" \
         labwc
