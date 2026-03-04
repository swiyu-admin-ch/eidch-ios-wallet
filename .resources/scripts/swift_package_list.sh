#!/bin/sh

export PATH="$PATH:/opt/homebrew/bin"

if command -v swift-package-list &> /dev/null; then
    OUTPUT_PATH=$SOURCE_ROOT/Modules/Features/BITSettings/Sources/BITSettings/Resources
    swift-package-list "$PROJECT_FILE_PATH" --output-path "$OUTPUT_PATH" --requires-license
else
    echo "warning: swift-package-list not installed"
fi