#!/bin/bash

# Polls cfprefsd directly for keyboard layout changes.
# Using `defaults` (IPC to cfprefsd) rather than watching the plist file on disk,
# because macOS batches preference writes — the file can lag seconds behind reality.

prev=""
while true; do
  plist=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources)
  # Combine keyboard layout name + input mode to detect both layout and input method switches
  layout=$(echo "$plist" | awk -F'"' '/KeyboardLayout Name/ { print $4 }')
  mode=$(echo "$plist" | awk -F'"' '/Input Mode/ { print $4 }')
  current="${layout}${mode}"
  if [ "$current" != "$prev" ]; then
    /opt/homebrew/bin/sketchybar --trigger keyboard_layout_change
    prev="$current"
  fi
  sleep 0.3
done
