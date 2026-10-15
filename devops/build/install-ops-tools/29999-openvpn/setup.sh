#! /usr/bin/bash
set -uexo pipefail

sudo apt-get install -y openvpn
mkdir -p /var/log/supervisor/openvpn
cp ./supervisord.conf /etc/supervisor/conf.d/openvpn.conf
