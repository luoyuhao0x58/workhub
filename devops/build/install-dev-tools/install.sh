#! /bin/bash
set -uexo pipefail

apt-get update -y
for filename in $(ls ./*-*/setup.sh | sort); do
  cd $(dirname $filename)
  ./setup.sh
  cd -
done