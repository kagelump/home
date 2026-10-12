#!/usr/bin/env bash
# Install my OpenCode config into ~/.config/opencode (Linux/macOS/WSL/Git Bash).
# Windows PowerShell users: use setup.ps1 instead.
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [--variant multiplier|dollars] [-h|--help]

Installs the OpenCode config from this repo into the global OpenCode
config directory (~/.config/opencode, or \$XDG_CONFIG_HOME/opencode).

Variants:
  multiplier  (default) OpenRouter model names show relative cost multipliers
                        e.g. "Claude Opus 4.6 (42.1x)"
  dollars     OpenRouter model names show real USD prices per million tokens
                        e.g. "Claude Opus 4.6 (\$5/\$25 per M)"

The chosen variant is installed as opencode.json (the file OpenCode reads).
The other variant is installed next to it as an inactive reference
(opencode-dollars.json / opencode-multiplier.json) so you can swap later.
Any file that would be overwritten with different content is backed up first.
EOF
}

VARIANT="multiplier"
while [ $# -gt 0 ]; do
  case "$1" in
    --variant)
      [ $# -ge 2 ] || { echo "error: --variant needs a value (multiplier|dollars)" >&2; exit 1; }
      VARIANT="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "error: unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

case "$VARIANT" in
  multiplier|dollars) ;;
  *) echo "error: unknown variant: $VARIANT (use multiplier|dollars)" >&2; exit 1 ;;
esac

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"

REPO_MULTIPLIER="$REPO_DIR/opencode/opencode.json"
REPO_DOLLARS="$REPO_DIR/opencode/opencode-dollars.json"

if [ "$VARIANT" = "dollars" ]; then
  ACTIVE="$REPO_DOLLARS"
  AUX="$REPO_MULTIPLIER"
  AUX_NAME="opencode-multiplier.json"
else
  ACTIVE="$REPO_MULTIPLIER"
  AUX="$REPO_DOLLARS"
  AUX_NAME="opencode-dollars.json"
fi

for f in "$ACTIVE" "$AUX"; do
  [ -f "$f" ] || { echo "error: missing $f — run this script from the repo root" >&2; exit 1; }
done

mkdir -p "$CONFIG_DIR"
STAMP="$(date +%Y%m%d-%H%M%S)"

install_file() {
  local src="$1" target="$2"
  if [ -f "$target" ]; then
    if cmp -s "$target" "$src"; then
      echo "unchanged: $target"
      return
    fi
    cp -p "$target" "$target.bak.$STAMP"
    echo "backed up: $(basename "$target") -> $(basename "$target").bak.$STAMP"
  fi
  cp "$src" "$target"
  echo "installed: $target"
}

install_file "$ACTIVE" "$CONFIG_DIR/opencode.json"
install_file "$AUX" "$CONFIG_DIR/$AUX_NAME"

echo
echo "Done. Active variant: $VARIANT"
echo "If OpenCode is already running, restart its service to pick up the config:"
echo "  opencode service restart"
