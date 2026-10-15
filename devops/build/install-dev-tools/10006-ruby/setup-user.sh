#! /bin/bash

source /etc/shell.rc

cp ./bashrc.sh "$HOME/.bashrc.d/$(basename "$(pwd -P)").sh"
source "$HOME/.bashrc.d/$(basename "$(pwd -P)").sh"

# user-level rbenv + ruby-build; RBENV_ROOT comes from bashrc.sh ($HOME/.rbenv)
git clone --depth=1 https://github.com/rbenv/rbenv.git "$RBENV_ROOT"
git clone --depth=1 https://github.com/rbenv/ruby-build.git "$RBENV_ROOT/plugins/ruby-build"
