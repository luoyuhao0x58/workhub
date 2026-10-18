#!/bin/bash
set -euo pipefail

export XDG_RUNTIME_DIR=/tmp/runtime-agent
mkdir -p "$XDG_RUNTIME_DIR"

# 音频栈：wireplumber + pipewire-pulse 与 pipewire 同进程组（supervisord stopasgroup 一并回收）
wireplumber &
pipewire-pulse &
exec pipewire
