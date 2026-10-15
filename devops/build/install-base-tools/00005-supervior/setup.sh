#! /usr/bin/bash
set -uexo pipefail

sudo apt-get install -y supervisor

sed -e "s|@@UNIX_HTTP_SERVER_USER@@|${BUILD_USER_NAME}|g" \
    -e "s|@@UNIX_HTTP_SERVER_GROUP@@|${BUILD_GROUP_NAME}|g" \
    ./supervisord.conf.tpl > /etc/supervisor/supervisord.conf