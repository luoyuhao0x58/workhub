#! /bin/bash
# Desktop action menu, bound to right-click on the root window (Super+D does the
# same). fuzzel renders it; under wlroots it cannot follow the injected pointer,
# so pick an entry with the arrow keys and Enter instead of the mouse.
set -euo pipefail

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-agent}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"

choice="$(
  printf '%s\n' \
    'Terminal' \
    'Files' \
    'Browser' \
    'Applications' \
    'Clipboard history' \
    'Screenshot' \
    'Log out' |
    fuzzel --dmenu --prompt 'Action: ' --lines 8
)" || exit 0

case "$choice" in
  Terminal) exec foot ;;
  Files) exec nautilus ;;
  Browser) exec firefox ;;
  Applications) exec gui-app-launcher.sh ;;
  'Clipboard history') exec gui-clipboard-history.sh ;;
  Screenshot) exec gui-screenshot.sh ;;
  'Log out') exec supervisorctl -c /etc/supervisord.conf stop 'gui:*' ;;
  *) exit 0 ;;
esac
