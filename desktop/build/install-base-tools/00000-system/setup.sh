#! /usr/bin/bash
set -uexo pipefail

# DNF_MIRROR lets a build point dnf at a domestic mirror (see Dockerfile.china).
# Empty means: keep the stock Fedora repositories.
DNF_MIRROR="${DNF_MIRROR:-}"
if [ -n "$DNF_MIRROR" ]; then
  sed -i \
    -e 's|^metalink=|#metalink=|g' \
    -e "s|^#baseurl=http://download.example/pub/fedora/linux|baseurl=${DNF_MIRROR}|g" \
    /etc/yum.repos.d/fedora*.repo
  # domestic mirrors do not carry the cisco h264 repo; leaving it enabled
  # aborts the whole transaction with "No valid source" instead of skipping it
  sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/fedora-cisco-openh264.repo
fi

dnf install -y --setopt=install_weak_deps=False \
  ca-certificates curl wget rsync tar gzip xz unzip \
  git sudo passwd shadow-utils procps-ng findutils which util-linux \
  iproute iputils hostname \
  tzdata glibc-langpack-en glibc-langpack-zh \
  less jq tree file vim-minimal openssl

ln -fs "/usr/share/zoneinfo/${BUILD_TZ}" /etc/localtime

# C.UTF-8 keeps tool output stable; zh_CN.UTF-8 stays available for GUI apps
# that insist on a Chinese locale.
cat > /etc/locale.conf << 'EOF'
LANG=C.UTF-8
EOF

cat > /etc/profile.d/history.sh << 'EOF'
export HISTFILESIZE=100000
export HISTCONTROL=ignoredups
export HISTSIZE=10000
export HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S]  "
EOF
