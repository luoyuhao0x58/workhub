#! /bin/bash
set -euo pipefail

# Configure China acceleration mirrors for all runtime sources.
# Runs as root inside the image. Idempotent - safe to run repeatedly.
#
# Layout:
#   install.sh  - entry point; runs system-wide modules, then injects
#                 per-language mirror env vars into ~/.bashrc.d
#   lib.sh      - shared helpers (AGENT_USER, inject_bashrc)
#   system/*.sh - system-wide source configs (/etc files, global registry)
#   langs/*.sh  - declarative per-language mirror env var data modules
#
# Runtime sources only; build-time download sources (node tarball,
# k8s/mongosh apt repos, php build sources) are intentionally excluded.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib.sh"

echo "== configure-china-mirrors: system-wide configs =="
for module in "$DIR"/system/*.sh; do
  [ -f "$module" ] || continue
  bash "$module"
done

echo "== configure-china-mirrors: per-language bashrc injection =="
if getent passwd "$AGENT_USER" > /dev/null; then
  sudo -u "$AGENT_USER" -H bash -s <<SCRIPT
set -euo pipefail
source "$DIR/lib.sh"
bashrc_dir="\$HOME/.bashrc.d"
[ -d "\$bashrc_dir" ] || exit 0
for f in "$DIR"/langs/*.sh; do
  [ -f "\$f" ] || continue
  lang="\$(basename "\$f" .sh)"
  source "\$f"
  [ -n "\${MIRROR_CONTENT:-}" ] || continue
  # discover the actual bashrc file by its -<lang>.sh suffix at runtime,
  # so renumbering the tool dirs does not require touching this module
  for target in "\$bashrc_dir"/*-"\$lang".sh; do
    [ -f "\$target" ] || continue
    inject_bashrc "\$target" "\$lang" "\$MIRROR_CONTENT"
  done
done
SCRIPT
fi

echo "configure-china-mirrors: done"
