#! /usr/bin/bash
set -uexo pipefail

# Audio and Wayland baseline. libICE/libSM are pcmflux's X11 fallback
# dependencies: without them audio capture reports "pcmflux library not found"
# and stays off. pipewire-utils brings pw-cli/pw-cat for verifying the sink from
# inside the session.
#
# labwc is the session compositor. It runs on the headless backend because the
# container has no DRM node; Xwayland is pulled in explicitly because X11
# clients (firefox, GTK dialogs) need the bridge running.
dnf install -y --setopt=install_weak_deps=False \
  labwc \
  xorg-x11-server-Xwayland \
  pipewire \
  pipewire-pulseaudio \
  wireplumber \
  dbus-daemon \
  mesa-dri-drivers \
  mesa-libEGL \
  mesa-libgbm \
  libva \
  libICE \
  libSM \
  pipewire-utils
