#! /bin/bash
set -euo pipefail

# Switch cargo to rsproxy at the system-wide fallback path.
# Cargo probes .cargo/config.toml upward from the cwd with /.cargo/config.toml
# at the top of that chain (Cargo Book "Hierarchical structure"); it does NOT
# read /etc/cargo. $CARGO_HOME/config.toml would also work but is user-scoped.
mkdir -p /.cargo
cat > /.cargo/config.toml << 'EOF'
[source.crates-io]
replace-with = 'rsproxy-sparse'
[source.rsproxy]
registry = "https://rsproxy.cn/crates.io-index"
[source.rsproxy-sparse]
registry = "sparse+https://rsproxy.cn/index/"
[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"
[net]
git-fetch-with-cli = true
EOF
