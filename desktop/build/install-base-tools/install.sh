#! /bin/bash
set -uexo pipefail

for filename in $(ls ./*-*/setup.sh | sort); do
  cd "$(dirname "$filename")"
  ./setup.sh
  cd -
done
