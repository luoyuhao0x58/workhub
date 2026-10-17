#! /usr/bin/bash
set -uexo pipefail

cp /tmp/emacs.sh "$HOME/.bashrc.d/$(basename "$(pwd -P)").sh"
chmod a+x "$HOME/.bashrc.d/$(basename "$(pwd -P)").sh"
