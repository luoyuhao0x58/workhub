#! /usr/bin/bash
set -uexo pipefail

# 会话运行时目录（构建期预建；gui-dbus wrapper 启动时也会确保存在）
mkdir -p /tmp/runtime-agent
chown "$BUILD_USER_NAME" /tmp/runtime-agent
chmod 700 /tmp/runtime-agent

# XWayland 的 X11 socket 目录
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# wrapper 脚本（supervisord program 入口）
install -m 0755 ./gui-dbus-session.sh /usr/local/bin/gui-dbus-session.sh
install -m 0755 ./gui-pipewire-session.sh /usr/local/bin/gui-pipewire-session.sh
install -m 0755 ./gui-labwc-session.sh /usr/local/bin/gui-labwc-session.sh
install -m 0755 ./gui-selkies-session.sh /usr/local/bin/gui-selkies-session.sh

# supervisord 配置（group:gui，手动启动）
cp ./gui-dbus.conf /etc/supervisor/conf.d/gui-dbus.conf
cp ./gui-pipewire.conf /etc/supervisor/conf.d/gui-pipewire.conf
cp ./gui-labwc.conf /etc/supervisor/conf.d/gui-labwc.conf
cp ./gui-selkies.conf /etc/supervisor/conf.d/gui-selkies.conf
cp ./gui-group.conf /etc/supervisor/conf.d/gui-group.conf

mkdir -p \
  /var/log/supervisor/gui-dbus \
  /var/log/supervisor/gui-pipewire \
  /var/log/supervisor/gui-labwc \
  /var/log/supervisor/gui-selkies
