#!/usr/bin/env bash
set -euo pipefail

CONTEXT="${1:-git hook}"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

cd "${REPO_ROOT}"

echo "[${CONTEXT}] Running mise pre-commit..."
mise pre-commit

echo "[${CONTEXT}] Checks passed."
