#! /usr/bin/bash
set -uexo pipefail

apt-get install -y tmux

cp ./tmux.conf /etc/tmux.conf