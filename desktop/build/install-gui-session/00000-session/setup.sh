#! /usr/bin/bash
set -uexo pipefail

SESSION_USER="${BUILD_USER_NAME}"
SESSION_HOME="${BUILD_USER_HOME}"

# Runtime directories. Recreated at container start by gui-dbus-session.sh as
# well, because /tmp and /run are tmpfs.
mkdir -p /tmp/runtime-agent /tmp/.X11-unix
chown "$SESSION_USER" /tmp/runtime-agent
chmod 700 /tmp/runtime-agent
chmod 1777 /tmp/.X11-unix

install -m 0755 ./gui-dbus-session.sh /usr/local/bin/gui-dbus-session.sh
install -m 0755 ./gui-pipewire-session.sh /usr/local/bin/gui-pipewire-session.sh
install -m 0755 ./gui-labwc-session.sh /usr/local/bin/gui-labwc-session.sh
install -m 0755 ./gui-selkies-session.sh /usr/local/bin/gui-selkies-session.sh

for name in gui-dbus gui-pipewire gui-labwc gui-selkies; do
  sed -e "s|@@SESSION_USER@@|${SESSION_USER}|g" \
      -e "s|@@SESSION_HOME@@|${SESSION_HOME}|g" \
      "./${name}.ini.tpl" > "/etc/supervisord.d/${name}.ini"
  mkdir -p "/var/log/supervisor/${name}"
done
cp ./gui-group.ini /etc/supervisord.d/gui-group.ini

# Session environment for interactive shells: without it, GUI apps launched
# from `docker compose exec` cannot find the compositor.
install -d -o "$SESSION_USER" -g "$BUILD_GROUP_NAME" "$SESSION_HOME/.config"
cat > "$SESSION_HOME/.config/desktop-session.env" << 'EOF'
export XDG_RUNTIME_DIR=/tmp/runtime-agent
export WAYLAND_DISPLAY=wayland-0
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/runtime-agent/bus
export XDG_CURRENT_DESKTOP=labwc
export XDG_SESSION_TYPE=wayland
# fcitx5 input method. Wayland-native clients (foot, GTK4) reach it through
# text-input-v3 with no variables set. GTK_IM_MODULE stays unset on purpose:
# forcing it to fcitx takes GTK4 off the native path and nautilus then shows
# neither preedit nor candidate window. The two below cover clients with no
# native path: Qt and Xwayland.
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
EOF
chown "$SESSION_USER:$BUILD_GROUP_NAME" "$SESSION_HOME/.config/desktop-session.env"

if ! grep -q 'desktop-session.env' "$SESSION_HOME/.bashrc"; then
  cat >> "$SESSION_HOME/.bashrc" << 'EOF'

# GUI session environment (labwc/selkies)
for env_file in "$HOME/.config/desktop-session.env"; do
  [ -f "$env_file" ] && . "$env_file"
done
EOF
fi
chown "$SESSION_USER:$BUILD_GROUP_NAME" "$SESSION_HOME/.bashrc"
