#! /bin/bash
set -uexo pipefail

# https://github.com/nvm-sh/nvm?tab=readme-ov-file#manual-install

# install nvm
export NVM_DIR="$HOME/.nvm" && (
  git clone --depth=1 https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$NVM_DIR/nvm.sh"

cp /tmp/nodejs.sh "$HOME/.bashrc.d/$(basename "$(pwd -P)").sh"
( source "$HOME/.bashrc.d/$(basename "$(pwd -P)").sh" ; nvm alias default system )
