#! /usr/bin/bash
set -uexo pipefail

sudo --preserve-env=BUILD_OPENSPEC_VERSION -u "$BUILD_USER_NAME" ./setup-user.sh
