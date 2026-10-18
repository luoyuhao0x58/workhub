#! /usr/bin/bash
set -uexo pipefail

SESSION_USER="${BUILD_USER_NAME}"
SESSION_HOME="${BUILD_USER_HOME}"

# fcitx5 is the input method framework. Its Wayland frontend speaks the native
# zwp_input_method_v2 protocol that labwc exposes, so clients that implement
# zwp_text_input_v3 - foot, GTK3, GTK4 - need no environment variable and no
# toolkit module. fcitx5-gtk and fcitx5-qt are installed anyway: they cost
# little and cover the toolkits that have no native path of their own.
dnf install -y --setopt=install_weak_deps=False \
  fcitx5 \
  fcitx5-chinese-addons \
  fcitx5-gtk \
  fcitx5-qt

# The input method group is written by hand. The only other way to populate it
# is fcitx5-configtool, which needs a live GUI session and a mouse.
#
# These go to /etc/xdg/fcitx5, not $SESSION_HOME/.config/fcitx5. The home
# directory is a bind-mounted volume, so whatever the image installs there at
# build time is hidden once the mount lands, and the settings silently do
# nothing. fcitx5 falls back to /etc/xdg when the user config has no entry.
install -Dm 0644 ./profile /etc/xdg/fcitx5/profile
install -Dm 0644 ./pinyin.conf /etc/xdg/fcitx5/conf/pinyin.conf

install -Dm 0755 ./gui-fcitx5-session.sh /usr/local/bin/gui-fcitx5-session.sh

sed -e "s|@@SESSION_USER@@|${SESSION_USER}|g" \
    -e "s|@@SESSION_HOME@@|${SESSION_HOME}|g" \
    ./gui-fcitx5.ini.tpl > /etc/supervisord.d/gui-fcitx5.ini
mkdir -p /var/log/supervisor/gui-fcitx5
