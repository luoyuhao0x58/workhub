#! /usr/bin/bash
set -uexo pipefail

# use for mount vscode remote server volume
sudo -u "$BUILD_USER_NAME" mkdir "$BUILD_USER_HOME/.vscode-server"