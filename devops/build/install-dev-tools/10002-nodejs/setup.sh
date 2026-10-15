#! /bin/bash
set -uexo pipefail

VERSION=$(curl -sL "https://nodejs.org/dist/index.json" | jq -r '[.[] | select(.lts != false)] | first | .version')
ARCH=$(uname -m)
case $ARCH in
  x86_64)  ARCH="x64" ;;
  aarch64) ARCH="arm64" ;;
esac
filename=node-${VERSION}-linux-${ARCH}.tar.xz
curl -LO https://nodejs.org/dist/${VERSION}/${filename}
tar -xJf ${filename} -C /usr/local --strip-components=1 --exclude='*.md' --exclude='LICENSE'

corepack enable

cp ./bashrc.sh.tpl /tmp/nodejs.sh
chmod a+x /tmp/nodejs.sh

sudo -u "$BUILD_USER_NAME" ./setup-user.sh
