#! /bin/bash
set -euo pipefail

cat > /etc/pip.conf << 'EOF'
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
extra-index-url = https://mirrors.volces.com/pypi/simple/
trusted-host =
    mirrors.aliyun.com
    mirrors.volces.com
EOF
