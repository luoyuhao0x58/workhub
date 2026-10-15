#! /usr/bin/bash
set -uexo pipefail

function get_arch() {
    a=$(uname -m)
    case ${a} in
    "x86_64" | "amd64")
        echo "amd64"
        ;;
    "i386" | "i486" | "i586")
        echo "386"
        ;;
    "aarch64" | "arm64")
        echo "arm64"
        ;;
    "armv6l" | "armv7l")
        echo "arm"
        ;;
    *)
        echo ""
        ;;
    esac
}

version=$(basename $(curl -I https://github.com/mvdan/sh/releases/latest 2>/dev/null | grep location | cut -d ' ' -f 2) | tr -cd '0-9.')
curl -fsSL "https://github.com/mvdan/sh/releases/download/v${version}/shfmt_v${version}_linux_$(get_arch)" -o /usr/local/bin/shfmt
chmod a+x /usr/local/bin/shfmt
