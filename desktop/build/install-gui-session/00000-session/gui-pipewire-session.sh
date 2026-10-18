#! /bin/bash
set -euo pipefail

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-agent}"
mkdir -p "$XDG_RUNTIME_DIR"

# pipewire owns the server socket, wireplumber the policy, pipewire-pulse the
# PulseAudio compatibility layer that pcmflux records from. supervisord's
# stopasgroup/killasgroup reaps all three together.
pipewire &

for _ in $(seq 1 120); do
  [ -S "$XDG_RUNTIME_DIR/pipewire-0" ] && break
  sleep 0.5
done
[ -S "$XDG_RUNTIME_DIR/pipewire-0" ] || exit 1

wireplumber &
pipewire-pulse &

# stay in the foreground; a child exiting makes supervisord restart the group
wait -n
