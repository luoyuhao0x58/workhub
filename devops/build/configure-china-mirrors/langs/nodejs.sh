#! /bin/bash
# Mirror env vars for nodejs (nvm / corepack). Sourced by install.sh.
# The lang id is the file name (nodejs); the target bashrc file is
# discovered at runtime via ~/.bashrc.d/*-nodejs.sh.

MIRROR_CONTENT='export NVM_NODEJS_ORG_MIRROR=${NVM_NODEJS_ORG_MIRROR:-https://npmmirror.com/mirrors/node/}
export COREPACK_NPM_REGISTRY=${COREPACK_NPM_REGISTRY:-https://registry.npmmirror.com}'
