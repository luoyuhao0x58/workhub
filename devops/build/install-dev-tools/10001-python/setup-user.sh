#! /usr/bin/bash
set -uexo pipefail

cp ./bashrc.sh.tpl "$HOME/.bashrc.d/$(basename "$(pwd -P)").sh"
chmod a+x "$HOME/.bashrc.d/$(basename "$(pwd -P)").sh"
mkdir -p ~/.local/

mkdir -p ~/.config/ruff/
cp ./ruff.toml ~/.config/ruff/
