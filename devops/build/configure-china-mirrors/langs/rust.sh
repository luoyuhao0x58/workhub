#! /bin/bash
# Mirror env vars for rust (rustup). Sourced by install.sh.
# The lang id is the file name (rust); the target bashrc file is
# discovered at runtime via ~/.bashrc.d/*-rust.sh.

MIRROR_CONTENT='export RUSTUP_UPDATE_ROOT=${RUSTUP_UPDATE_ROOT:-https://rsproxy.cn/rustup}
export RUSTUP_DIST_SERVER=${RUSTUP_DIST_SERVER:-https://rsproxy.cn}'
