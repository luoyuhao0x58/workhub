# >>> mirrors: rust >>>
# <<< mirrors: rust <<<

# User-level rustup manages multi-version toolchains under ~/.rustup.
# The image ships no Rust versions - install on demand with
# `rustup install stable` (versions persist via the ~/.rustup/toolchains
# volume). A user-provided RUSTUP_HOME/CARGO_HOME is honored.
export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"
export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
export PATH="$CARGO_HOME/bin:$PATH"
