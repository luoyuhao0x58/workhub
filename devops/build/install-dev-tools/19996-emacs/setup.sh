#! /usr/bin/bash
set -uexo pipefail

# Emacs without X/GUI support, keeping the image slim.
apt-get install -y --no-install-recommends emacs-nox

# Pin the daemon socket under /var/run, keyed by UID: the build user is
# renamed at container start (name and home change, the uid does not), so
# nothing here may reference the user by name. The directory must be
# created at build time and owned by the uid: /var/run is root-owned,
# and no logind exists inside the container to set up per-user runtime
# dirs.
install -d -m 755 /var/run/emacs
install -d -m 700 -o "$BUILD_UID" -g "$BUILD_GID" /var/run/emacs/"$BUILD_UID"
socket_dir=/var/run/emacs/"$BUILD_UID"

# Register the user-level daemon with supervisor, injecting the uid and
# socket path (NOT the user name, which changes at runtime).
sed -e "s|@@BUILD_UID@@|${BUILD_UID}|g" \
    -e "s|@@EMACS_SOCKET_DIR@@|${socket_dir}|g" \
    ./emacs.conf.tpl > /etc/supervisor/conf.d/emacs.conf

# Install the `em` client helper for the user, following the golang/nodejs
# convention of staging the template in /tmp for the unprivileged copy.
# Rendered with the same socket path so client and daemon stay in sync.
sed -e "s|@@EMACS_SOCKET_DIR@@|${socket_dir}|g" \
    ./bashrc.sh.tpl > /tmp/emacs.sh
chmod a+x /tmp/emacs.sh

sudo -u "$BUILD_USER_NAME" ./setup-user.sh
