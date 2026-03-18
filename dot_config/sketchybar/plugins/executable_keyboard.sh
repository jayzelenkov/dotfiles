#!/bin/bash

# Extract the KeyboardLayout Name value (quoted field after '=') from the active source
LAYOUT="$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources \
  | awk -F'"' '/KeyboardLayout Name/ { print $4 }')"

case "$LAYOUT" in
  "U.S.")      SHORT_LAYOUT="US" ;;
  Dvorak*)     SHORT_LAYOUT="DV" ;;
  Russian*)    SHORT_LAYOUT="RU" ;;
  German*)     SHORT_LAYOUT="DE" ;;
  Spanish*)    SHORT_LAYOUT="ES" ;;
  French*)     SHORT_LAYOUT="FR" ;;
  Portuguese*) SHORT_LAYOUT="PT" ;;
  Italian*)    SHORT_LAYOUT="IT" ;;
  Japanese*)   SHORT_LAYOUT="JA" ;;
  Korean*)     SHORT_LAYOUT="KO" ;;
  Chinese*)    SHORT_LAYOUT="ZH" ;;
  Arabic*)     SHORT_LAYOUT="AR" ;;
  Hebrew*)     SHORT_LAYOUT="HE" ;;
  Greek*)      SHORT_LAYOUT="EL" ;;
  Ukrainian*)  SHORT_LAYOUT="UK" ;;
  Polish*)     SHORT_LAYOUT="PL" ;;
  Turkish*)    SHORT_LAYOUT="TR" ;;
  # Fallback: first two letters of the first word, uppercased
  *) SHORT_LAYOUT="$(echo "$LAYOUT" | awk '{print toupper(substr($1,1,2))}')" ;;
esac

sketchybar --set keyboard label="$SHORT_LAYOUT"
