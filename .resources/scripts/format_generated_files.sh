#!/bin/sh

export PATH="$PATH:/opt/homebrew/bin"

if which swiftformat > /dev/null; then
  for(( i=0; i<SCRIPT_INPUT_FILE_COUNT; i++ ));
  do
    eval file="\$SCRIPT_INPUT_FILE_${i}"
    swiftformat $file
  done
else
  echo "warning: SwiftFormat not installed, download from# https://github.com/nicklockwood/SwiftFormat"
fi
