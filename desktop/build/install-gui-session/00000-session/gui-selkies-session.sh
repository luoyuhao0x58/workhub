#! /bin/bash
set -euo pipefail

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-agent}"
# supervisord inherits HOME from root; point it at the session user's home so
# ~ resolves to /mnt/workspace instead of /root
export HOME="$(getent passwd "${SESSION_USER:-agent}" | cut -d: -f6)"
# labwc owns the session and publishes wayland-0
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"

for _ in $(seq 1 120); do
  [ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ] && break
  sleep 0.5
done
[ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ] || exit 1

# --public: selkies defaults to loopback only, which docker's published
# port cannot reach; --addr must not be combined with it
ARGS=(
  --public
  --wayland
  --wayland-host-display="$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
  --port="${GUI_PORT:-1121}"
  # H.264 wants frame dimensions on a 16 pixel boundary; without this the
  # session resolution follows the client viewport literally.
  --force-aligned-resolution=true
)

# The password lives under $HOME (a persistent volume), so it survives
# container recreation - unlike the devops image, where it sat in /tmp.
AUTH_FILE="$HOME/.config/selkies/auth"
AUTH="${GUI_AUTH_PASSWORD:-}"
if [ -z "$AUTH" ] && [ -f "$AUTH_FILE" ]; then
  AUTH="$(cat "$AUTH_FILE")"
fi
if [ -z "$AUTH" ]; then
  AUTH="$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c 16)"
  mkdir -p "$(dirname "$AUTH_FILE")"
  (umask 077; echo "$AUTH" > "$AUTH_FILE")
  echo "WARNING: GUI_AUTH_PASSWORD unset, generated a random password for user ${SESSION_USER:-agent}: $AUTH (stored in $AUTH_FILE)" >&2
fi

ARGS+=(
  --enable-basic-auth=true
  --basic-auth-user="${SESSION_USER:-agent}"
  --basic-auth-password="$AUTH"
)

exec selkies "${ARGS[@]}"
