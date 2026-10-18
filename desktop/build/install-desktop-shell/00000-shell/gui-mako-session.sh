#! /bin/bash
set -euo pipefail

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-agent}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"

# supervisord only orders process start, it does not wait for sockets. The
# the compositor socket appears a moment after labwc starts, so wait for it
# instead of letting mako exit and get restarted in a loop.
for _ in $(seq 1 120); do
  [ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ] && break
  sleep 0.5
done
[ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ] || exit 1

exec mako
