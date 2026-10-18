#!/bin/bash
set -euo pipefail

# GUI 会话前置（以 root 运行）：
# - 确保 XDG_RUNTIME_DIR（dbus/pipewire/wayland 均依赖 0700 运行时目录）
# - 确保 XWayland 的 X11 socket 目录
# - 确保 dbus system bus 目录（容器 /run 为 tmpfs，每次启动需重建）
mkdir -p /tmp/runtime-agent
chown agent /tmp/runtime-agent
chmod 700 /tmp/runtime-agent
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix
mkdir -p /run/dbus
chmod 755 /run/dbus
exec dbus-daemon --system --nofork --nopidfile
