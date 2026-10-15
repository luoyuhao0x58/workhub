#! /usr/bin/bash
set -uexo pipefail

apt-get install -y vim-nox

cp ./vimrc.local /etc/vim/vimrc.local
update-alternatives --set editor /usr/bin/vim.nox