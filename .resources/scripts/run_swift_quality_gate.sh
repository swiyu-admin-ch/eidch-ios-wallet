#!/usr/bin/env bash
set -euo pipefail

CONTEXT="${1:-git hook}"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

cd "${REPO_ROOT}"

MISE="$HOME/.local/bin/mise"
[ -x "$MISE" ] || MISE="/opt/homebrew/bin/mise"
if [ ! -x "$MISE" ]; then
  echo "[${CONTEXT}] error: mise not found at ~/.local/bin/mise or /opt/homebrew/bin/mise"
  exit 1
fi
echo "[${CONTEXT}] Running mise quality:pre-commit..."
mise quality:pre-commit

echo "[${CONTEXT}] Checks passed."
