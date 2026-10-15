#! /usr/bin/bash
set -uexo pipefail

apt-get install -y zsh
echo '[ -f /etc/shell.rc ] && source /etc/shell.rc' >> /etc/zsh/zshrc

sudo -u $BUILD_USER_NAME ./setup-user.sh
