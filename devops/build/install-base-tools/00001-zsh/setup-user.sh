#! /usr/bin/bash
set -uexo pipefail

git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
cp ./zshrc.zsh ~/.zshrc

sudo usermod -s $(which zsh) $(id -un)
