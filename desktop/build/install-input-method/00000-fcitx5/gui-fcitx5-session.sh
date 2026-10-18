#! /bin/bash
set -euo pipefail

# labwc publishes its Wayland socket a moment after supervisor forks it, and
# supervisor's priority only orders the forks - it does not wait for readiness.
# Starting fcitx5 before the socket exists leaves it without a Wayland frontend
# for the whole session, logging "Failed to open wayland connection" once and
# then silently accepting no input at all. Wait for the socket first.
socket="${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}"
for _ in $(seq 1 100); do
  [ -S "$socket" ] && break
  sleep 0.1
done

if [ ! -S "$socket" ]; then
  echo "gui-fcitx5-session: ${socket} never appeared, starting anyway" >&2
fi

exec /usr/bin/fcitx5
