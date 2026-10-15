#! /bin/bash
set -uexo pipefail

sudo --preserve-env=BUILD_PI_VERSION -u "$BUILD_USER_NAME" ./setup-user.sh
