#! /usr/bin/bash
set -uexo pipefail

# Application set follows Omarchy's choices where Fedora ships the package:
# foot (terminal), nautilus (files), fuzzel (launcher), mako (notifications),
# grim/slurp/swappy (screenshots), wl-clipboard/cliphist (clipboard history),
# imv/mpv (media). Omarchy's own GUI apps, its Arch-only tooling and every AI
# component are deliberately out of scope.
dnf install -y --setopt=install_weak_deps=False \
  foot \
  nautilus \
  gvfs \
  firefox \
  xdg-utils \
  fuzzel \
  mako \
  libnotify \
  grim \
  slurp \
  swappy \
  wl-clipboard \
  cliphist \
  wtype \
  swaybg \
  imv \
  mpv \
  google-noto-sans-cjk-fonts \
  google-noto-color-emoji-fonts \
  dejavu-sans-fonts \
  dejavu-sans-mono-fonts \
  jetbrains-mono-fonts \
  fontawesome-fonts

# Default handlers so double-clicking a file in nautilus does the obvious thing.
# Written as a system-wide mimeapps.list on purpose: `xdg-mime default` run as
# root would land in /root/.local/share/applications, which the agent user
# never reads (this was silently a no-op before).
cat > /etc/xdg/mimeapps.list << 'EOF'
[Default Applications]
image/png=imv.desktop
image/jpeg=imv.desktop
image/gif=imv.desktop
image/webp=imv.desktop
image/svg+xml=imv.desktop
video/mp4=mpv.desktop
video/x-matroska=mpv.desktop
video/webm=mpv.desktop
video/quicktime=mpv.desktop
inode/directory=org.gnome.Nautilus.desktop
EOF
