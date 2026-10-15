#! /bin/bash
set -uexo pipefail

# rustup dist naming
case $(uname -m) in
  x86_64)  RUST_ARCH="x86_64-unknown-linux-gnu" ;;
  aarch64) RUST_ARCH="aarch64-unknown-linux-gnu" ;;
  *) echo "unsupported arch: $(uname -m)" >&2; exit 1 ;;
esac

# Download rustup-init and verify its official sha256 before running it.
# sh.rustup.rs pipes an unverified remote script and binary - downloading
# the binary + its checksum from the official dist server instead is the
# only way to get a verifiable install.
RUSTUP_BASE="https://static.rust-lang.org/rustup/dist/${RUST_ARCH}"
curl -fsSL -o /tmp/rustup-init "$RUSTUP_BASE/rustup-init"
curl -fsSL -o /tmp/rustup-init.sha256 "$RUSTUP_BASE/rustup-init.sha256"
( cd /tmp && sha256sum -c rustup-init.sha256 )
chmod +x /tmp/rustup-init

# User-level install only: no system /opt/rust, no default toolchain.
# Agents install toolchains on demand (rustup install stable); versions
# persist via the ~/.rustup/toolchains volume.
sudo -u "$BUILD_USER_NAME" ./setup-user.sh
rm -f /tmp/rustup-init /tmp/rustup-init.sha256
