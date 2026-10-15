#! /bin/bash
# Shared helpers for configure-china-mirrors modules.
#
# inject_bashrc runs inside a `sudo -u $AGENT_USER` subshell, so $HOME
# is the agent user's home directory there.

AGENT_USER=${AGENT_USER:-agent}

# Fill the mirror placeholder block of a language bashrc file.
# The placeholder is baked into the official-image templates:
#   # >>> mirrors: <lang> >>>
#   # <<< mirrors: <lang> <<<
# Re-running replaces the previous block, so this is idempotent.
#
# Usage: inject_bashrc <path-to-bashrc-file> <lang> <multiline-content>
inject_bashrc() {
  local file="$1" lang="$2" content="$3"
  local begin="# >>> mirrors: ${lang} >>>"
  local end="# <<< mirrors: ${lang} <<<"

  [ -f "$file" ] || return 0

  # strip existing injected block, keep the marker lines
  awk -v begin="$begin" -v end="$end" '
    $0 == begin { inside=1; print; next }
    $0 == end   { inside=0; print; next }
    inside { next }
    { print }
  ' "$file" > "$file.tmp"

  # fill the block right after the begin marker
  awk -v begin="$begin" -v content="$content" '
    BEGIN { n = split(content, lines, "\n") }
    $0 == begin { print; for (i = 1; i <= n; i++) print lines[i]; next }
    { print }
  ' "$file.tmp" > "$file"
  rm -f "$file.tmp"
}
