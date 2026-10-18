#! /bin/bash
set -euo pipefail

# Configure China acceleration mirrors for the desktop image's runtime sources.
# Runs as root inside the image. Idempotent - safe to run repeatedly.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "== configure-china-mirrors: system-wide configs =="
for module in "$DIR"/system/*.sh; do
  [ -f "$module" ] || continue
  bash "$module"
done

echo "configure-china-mirrors: done"
