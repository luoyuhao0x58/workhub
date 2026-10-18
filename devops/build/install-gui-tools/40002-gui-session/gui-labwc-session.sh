#!/bin/bash
set -euo pipefail

export XDG_RUNTIME_DIR=/tmp/runtime-agent
export WAYLAND_DISPLAY=wayland-0
export DISPLAY=:0

# 等待音频栈就绪
for i in $(seq 1 60); do
  [ -S "$XDG_RUNTIME_DIR/pipewire-0" ] && break
  sleep 1
done
[ -S "$XDG_RUNTIME_DIR/pipewire-0" ] || exit 1

# 清理上一次会话残留的 X11 socket（wlroots 的 Xwayland 用 displayfd 分配号，
# 残留会让 :0 漂移到 :1，而会话内 X11 应用依赖稳定的 DISPLAY=:0）
rm -f /tmp/.X11-unix/X* /tmp/.X*-lock

# headless 无 GPU：WLR_BACKENDS=headless + WLR_RENDERER=pixman 软件渲染
exec env WLR_BACKENDS=headless WLR_RENDERER=pixman labwc
