#!/bin/bash
set -euo pipefail

export XDG_RUNTIME_DIR=/tmp/runtime-agent
# supervisord program 的 HOME 继承自 root，重设为会话用户主目录（避免 ~ 解析到 /root）
export HOME="$(getent passwd agent | cut -d: -f6)"
export WAYLAND_DISPLAY=wayland-0

# 等待合成器就绪
for i in $(seq 1 60); do
  [ -S "$XDG_RUNTIME_DIR/wayland-0" ] && break
  sleep 1
done
[ -S "$XDG_RUNTIME_DIR/wayland-0" ] || exit 1

ARGS=(--wayland --wayland-host-display="$XDG_RUNTIME_DIR/wayland-0" --port=1121)

AUTH_FILE="$XDG_RUNTIME_DIR/selkies-auth"
AUTH="${GUI_AUTH_PASSWORD:-}"
if [ -n "$AUTH" ]; then
  ARGS+=(--enable-basic-auth=true --basic-auth-user=agent --basic-auth-password="$AUTH")
else
  # 未配置密码：首次生成随机密码并持久化（重启不变），避免 1121 无认证暴露
  if [ -f "$AUTH_FILE" ]; then
    AUTH="$(cat "$AUTH_FILE")"
  else
    AUTH="$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c 16)"
    echo "$AUTH" > "$AUTH_FILE"
    chmod 600 "$AUTH_FILE"
    echo "WARNING: GUI_AUTH_PASSWORD 未设置，已生成随机密码（浏览器登录用）: $AUTH（持久化于 $AUTH_FILE）" >&2
  fi
  ARGS+=(--enable-basic-auth=true --basic-auth-user=agent --basic-auth-password="$AUTH")
fi

exec selkies "${ARGS[@]}"
