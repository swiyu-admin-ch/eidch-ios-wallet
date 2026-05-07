#!/bin/sh

MISE="$HOME/.local/bin/mise"
[ -x "$MISE" ] || MISE="/opt/homebrew/bin/mise"
if [ ! -x "$MISE" ]; then
  echo "error: mise not found at ~/.local/bin/mise or /opt/homebrew/bin/mise"
  exit 1
fi

$MISE exec -- swiftformat --lint . # autocorrect: swiftformat .