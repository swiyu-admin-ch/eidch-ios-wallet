#!/bin/sh

MISE="$HOME/.local/bin/mise"
[ -x "$MISE" ] || MISE="/opt/homebrew/bin/mise"
if [ ! -x "$MISE" ]; then
  echo "error: mise not found at ~/.local/bin/mise or /opt/homebrew/bin/mise"
  exit 1
fi

OUTPUT_PATH="$SOURCE_ROOT/Modules/Features/BITSettings/Sources/BITSettings/Resources"
DERIVED_DATA_PATH="${BUILD_DIR%%/Build/*}"

if [ "$DERIVED_DATA_PATH" = "$BUILD_DIR" ] && [ -n "$PROJECT_TEMP_DIR" ]; then
  DERIVED_DATA_PATH="${PROJECT_TEMP_DIR%%/Build/*}"
fi

SOURCE_PACKAGES_PATH="$DERIVED_DATA_PATH/SourcePackages"

if [ ! -f "$SOURCE_PACKAGES_PATH/workspace-state.json" ]; then
  echo "error: Swift package workspace state not found at $SOURCE_PACKAGES_PATH/workspace-state.json"
  echo "BUILD_DIR=$BUILD_DIR"
  echo "PROJECT_TEMP_DIR=$PROJECT_TEMP_DIR"
  exit 1
fi

"$MISE" exec -- swift-package-list \
  "$PROJECT_FILE_PATH" \
  --custom-source-packages-path "$SOURCE_PACKAGES_PATH" \
  --output-type json \
  --output-path "$OUTPUT_PATH" \
  --requires-license
