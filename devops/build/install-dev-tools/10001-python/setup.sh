#! /bin/bash
set -uexo pipefail

apt install -y --no-install-recommends \
  python3 \
  python3-pip \
  python3-venv \
  python3-dev \
  python3-httpx \
  pipx

pipx install --global --system-site-packages uv
pipx install --global --system-site-packages ruff
pipx install --global --system-site-packages ty
pipx install --global --system-site-packages ipython

sudo -u "$BUILD_USER_NAME" ./setup-user.sh
