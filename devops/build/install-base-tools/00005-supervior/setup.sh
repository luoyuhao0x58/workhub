#! /usr/bin/bash
set -uexo pipefail

sudo apt-get install -y supervisor

sed -e "s|@@UNIX_HTTP_SERVER_UID@@|${BUILD_UID}|g" \
    -e "s|@@UNIX_HTTP_SERVER_GID@@|${BUILD_GID}|g" \
    ./supervisord.conf.tpl > /etc/supervisor/supervisord.conf
