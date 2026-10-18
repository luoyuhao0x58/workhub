#! /usr/bin/bash
set -uexo pipefail

# pixelflux/pcmflux are C extensions; Fedora 44 publishes manylinux wheels for
# them, but the compiler chain stays installed so a future release without a
# wheel can still build from source instead of failing the image build.
dnf install -y --setopt=install_weak_deps=False \
  pipx \
  gcc gcc-c++ make \
  python3-devel python3-cffi \
  libffi-devel cairo-devel pkgconf-pkg-config

# --system-site-packages lets selkies reuse the distro python instead of
# duplicating the standard library into the pipx venv
pipx install --global --system-site-packages selkies

selkies --version

# The shipped web client lets document.body overflow the viewport, which makes
# its own pointer math disagree with the resolution it asks the server for.
# See patch-selkies-css.py for the details.
install -m 0755 ./patch-selkies-css.py /usr/local/bin/patch-selkies-css.py
/usr/local/bin/patch-selkies-css.py

