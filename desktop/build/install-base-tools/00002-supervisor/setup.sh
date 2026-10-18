#! /usr/bin/bash
set -uexo pipefail

dnf install -y --setopt=install_weak_deps=False supervisor

# Fedora ships /etc/supervisord.conf with its own defaults; replace it so the
# socket ownership, log paths and include suffix match what the image expects.
sed -e "s|@@UNIX_HTTP_SERVER_UID@@|${BUILD_UID}|g" \
    -e "s|@@UNIX_HTTP_SERVER_GID@@|${BUILD_GID}|g" \
    ./supervisord.conf.tpl > /etc/supervisord.conf

mkdir -p /etc/supervisord.d /var/log/supervisor /run/supervisor
