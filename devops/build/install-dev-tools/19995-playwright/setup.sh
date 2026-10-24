#! /usr/bin/bash
set -uexo pipefail

pipx install --global --system-site-packages playwright

( source ./bashrc.sh ; mkdir -p "$PLAYWRIGHT_BROWSERS_PATH" ; chown -R "$BUILD_USER_NAME:$BUILD_GROUP_NAME" "$PLAYWRIGHT_BROWSERS_PATH" )

( sudo -u $BUILD_USER_NAME ./setup-user.sh )
