#! /usr/bin/bash
set -uexo pipefail

# Desktop shell: labwc (session compositor) + waybar (bar) + fuzzel (launcher and
# action menu) + mako (notifications) + screenshot/clipboard helpers.
#
# fuzzel is Wayland-native and does not follow the mouse under wlroots: selkies
# injects the pointer as an absolute warp, which labwc turns into enter/leave
# without wl_pointer.motion, so fuzzel's highlight never moves. It is therefore
# driven from the keyboard (Super+Space / Super+D, type to filter, Enter). That
# is the deliberate trade for working compositor keybinds: niri gave clickable
# menus but no keybinds at all, because its 26.04 release does not route
# virtual-keyboard events through its own bind pipeline.
dnf install -y --setopt=install_weak_deps=False \
  waybar \
  adwaita-icon-theme \
  python3

install -d /etc/xdg/labwc /etc/xdg/fuzzel /etc/xdg/mako \
  /etc/xdg/waybar /usr/share/workhub

# Configs live under /etc/xdg: home is a persistent volume, so anything written
# to ~/.config at build time would be masked at runtime.
install -m 0644 ./rc.xml /etc/xdg/labwc/rc.xml
# Deliberately defines no root-menu, which is what keeps a desktop right click
# from opening a menu that an injected pointer cannot dismiss.
install -m 0644 ./menu.xml /etc/xdg/labwc/menu.xml
install -m 0644 ./fuzzel.ini /etc/xdg/fuzzel/fuzzel.ini
install -m 0644 ./mako-config.ini /etc/xdg/mako/config
install -m 0644 ./waybar-config.jsonc /etc/xdg/waybar/config.jsonc
install -m 0644 ./waybar-style.css /etc/xdg/waybar/style.css

install -m 0755 ./gui-shell-session.sh /usr/local/bin/gui-shell-session.sh
install -m 0755 ./gui-mako-session.sh /usr/local/bin/gui-mako-session.sh
install -m 0755 ./gui-desktop-menu.sh /usr/local/bin/gui-desktop-menu.sh
install -m 0755 ./gui-app-launcher.sh /usr/local/bin/gui-app-launcher.sh
install -m 0755 ./gui-screenshot.sh /usr/local/bin/gui-screenshot.sh
install -m 0755 ./gui-clipboard-history.sh /usr/local/bin/gui-clipboard-history.sh

for name in gui-mako gui-shell; do
  sed -e "s|@@SESSION_USER@@|${BUILD_USER_NAME}|g" \
      -e "s|@@SESSION_HOME@@|${BUILD_USER_HOME}|g" \
      "./${name}.ini.tpl" > "/etc/supervisord.d/${name}.ini"
  mkdir -p "/var/log/supervisor/${name}"
done
