#! /bin/bash
set -uexo pipefail

mkdir -p ~/.g/bin
mkdir -p ~/.g/go
mkdir -p ~/.g/versions

arch="$1"
version=$(basename $(curl -I https://github.com/voidint/g/releases/latest 2>/dev/null | grep location | cut -d ' ' -f 2) | tr -cd '0-9.')
filename="g$version.linux-$arch.tar.gz"
curl -L "https://github.com/voidint/g/releases/download/v$version/$filename" -o "/tmp/$filename"
tar xzf "/tmp/$filename" -C ~/.g/bin

cp ./genv ~/.g/env

cat ./bashrc.sh.tpl >> "$HOME/.bashrc.d/$(basename "$(pwd -P)").sh"
