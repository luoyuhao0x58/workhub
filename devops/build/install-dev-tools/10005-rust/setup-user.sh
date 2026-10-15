#! /bin/bash
set -uexo pipefail

# User-level rustup: toolchains live in ~/.rustup, managed by the agent.
# No default toolchain is installed - the image ships no Rust versions;
# agents install them on demand (`rustup install stable`) and the versions
# persist via the ~/.rustup/toolchains volume.
export RUSTUP_HOME="$HOME/.rustup"
export CARGO_HOME="$HOME/.cargo"
export PATH="$CARGO_HOME/bin:$PATH"

/tmp/rustup-init -y --no-modify-path --default-toolchain none

cp ./bashrc.sh "$HOME/.bashrc.d/$(basename "$(pwd -P)").sh"
