#! /bin/bash
set -uexo pipefail

source ~/.bashrc.d/*-nodejs.sh || true
pnpm install -g "@earendil-works/pi-coding-agent@$BUILD_PI_VERSION"
