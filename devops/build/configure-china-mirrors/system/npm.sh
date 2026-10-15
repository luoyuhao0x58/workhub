#! /bin/bash
set -euo pipefail

# Switch npm registry (system-wide) and pnpm registry (agent) to npmmirror.
AGENT_USER=${AGENT_USER:-agent}

npm config set registry -g https://registry.npmmirror.com

if getent passwd "$AGENT_USER" > /dev/null; then
  sudo -u "$AGENT_USER" -H bash -c '
    /usr/local/bin/pnpm config set registry -g https://registry.npmmirror.com 2>/dev/null || true
  '
fi
