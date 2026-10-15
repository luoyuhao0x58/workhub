#! /bin/bash
set -euo pipefail

# Switch apt to Aliyun mirrors over HTTPS (plain HTTP leaves the package
# metadata open to tampering; Aliyun serves both protocols).
sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources
grep -q 'contrib non-free' /etc/apt/sources.list.d/debian.sources \
  || sed -i 's/Components: main/Components: main contrib non-free/g' /etc/apt/sources.list.d/debian.sources
