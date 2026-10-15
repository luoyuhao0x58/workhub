#! /bin/bash
set -uexo pipefail

source ~/.bashrc.d/*-nodejs.sh || true
pnpm install -g "@fission-ai/openspec@$BUILD_OPENSPEC_VERSION"
