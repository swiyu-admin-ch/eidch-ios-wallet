#!/bin/bash

# ANSI color codes
RESET="\033[0m"
RED="\033[0;31m"
LOCK_DIR="/tmp/build_module_lock"

MODULE_NAME=$(basename "$1")

# Create lock directory
mkdir -p "$LOCK_DIR"

# Error reporting function
report_error() {
    local operation=$1
    local error_msg=$2
    local LOCK_FILE="$LOCK_DIR/output.lock"
    while ! mkdir "$LOCK_FILE" 2>/dev/null; do
        sleep 0.01
    done
    printf "${RED}Error in module ${MODULE_NAME}${RESET}\n"
    printf "Operation: ${operation}\n"
    printf "Error: ${error_msg}\n\n"
    rm -rf "$LOCK_FILE"
    exit 1
}

cd "$1" || report_error "Changing directory" "Could not cd to $1"

# Process SwiftGen if configuration exists
if [ -f swiftgen.yml ]; then
    if ! swiftgen > /dev/null 2>&1; then
        report_error "SwiftGen" "Failed to generate code"
    fi
fi

# Format Swift code
if ! swiftformat --quiet . > /dev/null 2>&1; then
    report_error "SwiftFormat" "Failed to format code"
fi

exit 0
