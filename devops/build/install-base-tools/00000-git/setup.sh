#! /usr/bin/bash
set -uexo pipefail

apt-get install -y git

# configure git
git config --system core.quotepath false
git config --system color.ui auto
git config --system pull.ff only
git config --system pull.rebase true
git config --system init.defaultbranch main
git config --system credential.helper store