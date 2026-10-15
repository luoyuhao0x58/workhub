#! /usr/bin/bash
set -uexo pipefail

mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys
chmod 700 ~/.ssh && chmod 600 ~/.ssh/*
cp ./bashrc.sh "$HOME/.bashrc.d/$(basename "$(pwd -P)").sh"