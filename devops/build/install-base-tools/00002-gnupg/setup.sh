#! /usr/bin/bash
set -uexo pipefail

apt-get install -y gnupg2 pinentry-tty

echo 'export GPG_TTY=$(tty)' >>/etc/shell.rc
mkdir -p /etc/gnupg
printf 'pinentry-program /usr/bin/pinentry\ndefault-cache-ttl 604800\nmax-cache-ttl 604800\n' >/etc/gnupg/gpg-agent.conf

sudo -u "$BUILD_USER_NAME" ./setup-user.sh
