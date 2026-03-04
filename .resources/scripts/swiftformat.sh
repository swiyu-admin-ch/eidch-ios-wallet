#!/bin/sh

# Adds support for Apple Silicon brew directory

export PATH="$PATH:/opt/homebrew/bin"

if which swiftformat > /dev/null; then
  swiftformat --lint . # autocorrect: swiftformat .
else
  echo "warning: SwiftFormat not installed, download from# https://github.com/nicklockwood/SwiftFormat"
fi
