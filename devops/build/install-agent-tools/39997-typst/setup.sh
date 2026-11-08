#! /usr/bin/bash
set -uexo pipefail

function get_arch() {
    a=$(uname -m)
    case ${a} in
    "x86_64" | "amd64")
        echo "x86_64"
        ;;
    "aarch64" | "arm64")
        echo "aarch64"
        ;;
    "armv6l" | "armv7l")
        echo "armv7"
        ;;
    *)
        echo ""
        ;;
    esac
}

version=$(basename $(curl --retry 5 --retry-delay 5 --retry-all-errors -I https://github.com/typst/typst/releases/latest 2>/dev/null | grep location | cut -d ' ' -f 2) | tr -cd '0-9.')
mkdir -p /tmp/typst
curl --retry 5 --retry-delay 5 --retry-all-errors -fsSL "https://github.com/typst/typst/releases/download/v${version}/typst-$(get_arch)-unknown-linux-musl.tar.xz" -o /tmp/typst/typst.tar.zx
tar -xf /tmp/typst/typst.tar.zx -C /tmp/typst
install -m 755 /tmp/typst/typst-*/typst /usr/local/bin/typst
rm -rf /tmp/typst
