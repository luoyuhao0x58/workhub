#! /bin/bash
set -euo pipefail

# GUI session front-runner (runs as root):
# - XDG_RUNTIME_DIR is 0700 and owned by the session user - dbus, pipewire and
#   the compositor all refuse to work with a looser directory
# - /tmp/.X11-unix is the X11 socket directory XWayland writes into
# - /run is tmpfs, so the dbus and supervisor directories are recreated here
SESSION_USER="${SESSION_USER:-agent}"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-agent}"

mkdir -p "$RUNTIME_DIR" /tmp/.X11-unix /run/dbus /run/supervisor
chown "$SESSION_USER" "$RUNTIME_DIR"
chmod 700 "$RUNTIME_DIR"
chmod 1777 /tmp/.X11-unix

# Session bus: desktop apps (firefox, nautilus, mako) expect one, and without
# it pipewire's RTKit setup degrades to unprivileged scheduling.
# It must run as the session user: this wrapper is root (it owns the runtime
# directory), and a root-owned session bus refuses connections from uid 1000 -
# every client then fails with "Failed to acquire service name".
su-exec "$SESSION_USER" dbus-daemon --session \
  --address="unix:path=$RUNTIME_DIR/bus" --nofork --nopidfile &
for _ in $(seq 1 60); do
  [ -S "$RUNTIME_DIR/bus" ] && break
  sleep 0.2
done

exec dbus-daemon --system --nofork --nopidfile
