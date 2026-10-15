#! /bin/bash
set -uexo pipefail

# No system-wide Go: the g version manager is installed for the user
# (setup-user.sh) and agents install/switch Go versions themselves.
# Versions live in ~/.g/versions (persisted via compose volume).

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
    "s390x")
        echo "s390x"
        ;;
    "riscv64")
        echo "riscv64"
        ;;
    *)
        echo ""
        ;;
    esac
}

arch=$(get_arch)
[ -n "$arch" ] || { echo "unsupported arch: $(uname -m)" >&2; exit 1; }

sudo -u "$BUILD_USER_NAME" ./setup-user.sh "$arch"
