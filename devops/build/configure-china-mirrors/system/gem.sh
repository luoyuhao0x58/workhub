#! /bin/bash
set -euo pipefail

# Switch gem sources (system-wide + dev user) and bundle mirror (agent)
AGENT_USER=${AGENT_USER:-agent}

cat > /tmp/gemrc.china << 'EOF'
:sources:
  - https://mirrors.ustc.edu.cn/rubygems/
gem: "--no-document"
EOF

# 1) system-wide: resolve ruby's real sysconfdir. The distro ruby (installed
#    via apt) reads gemrc from /etc, so write it there for system `gem`.
#    User-level ~/.gemrc below is the guaranteed fallback for the dev user.
SYSCONFDIR=""
if command -v ruby >/dev/null 2>&1; then
  SYSCONFDIR="$(ruby -e 'print RbConfig::CONFIG["sysconfdir"]')"
fi
if [ -n "$SYSCONFDIR" ]; then
  mkdir -p "$SYSCONFDIR"
  cp /tmp/gemrc.china "$SYSCONFDIR/gemrc"
fi

# 2) user-level: ~/.gemrc is always read by gem and takes precedence over the
#    system file - guarantees the mirror applies for the dev user even if the
#    sysconfdir changes between builds or rubies.
if getent passwd "$AGENT_USER" > /dev/null; then
  USER_HOME="$(getent passwd "$AGENT_USER" | cut -d: -f6)"
  sudo -u "$AGENT_USER" -H cp /tmp/gemrc.china "$USER_HOME/.gemrc"
  sudo -u "$AGENT_USER" -H bash -c '
    source /etc/shell.rc 2>/dev/null || true
    command -v bundle >/dev/null 2>&1 && bundle config set --global mirror.https://rubygems.org https://mirrors.ustc.edu.cn/rubygems/ || true
  '
fi

rm -f /tmp/gemrc.china
