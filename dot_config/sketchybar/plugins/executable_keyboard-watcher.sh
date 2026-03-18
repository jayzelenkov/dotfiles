#!/bin/bash

# Polls cfprefsd directly for keyboard layout changes.
# Using `defaults` (IPC to cfprefsd) rather than watching the plist file on disk,
# because macOS batches preference writes — the file can lag seconds behind reality.

prev=""
while true; do
  current=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources \
    | awk -F'"' '/KeyboardLayout Name/ { print $4 }')
  if [ "$current" != "$prev" ]; then
    /opt/homebrew/bin/sketchybar --trigger keyboard_layout_change
    prev="$current"
  fi
  sleep 0.3
done
