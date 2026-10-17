#! /usr/bin/bash
set -uexo pipefail

apt-get install -y vim-nox neovim

cp ./vimrc.local /etc/vim/vimrc.local
update-alternatives --set editor /usr/bin/vim.nox
