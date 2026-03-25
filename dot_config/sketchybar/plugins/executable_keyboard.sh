#!/bin/bash

PLIST="$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources)"

# Try keyboard layout name first (covers hardware layouts like U.S., Russian, etc.)
LAYOUT="$(echo "$PLIST" | awk -F'"' '/KeyboardLayout Name/ { print $4 }')"

# If empty, the active source is an input method — extract its Input Mode identifier
INPUT_MODE=""
if [ -z "$LAYOUT" ]; then
  INPUT_MODE="$(echo "$PLIST" | awk -F'"' '/Input Mode/ { print $4 }')"
fi

if [ -n "$LAYOUT" ]; then
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
else
  # Input method mapping (macOS reports these via Input Mode, not KeyboardLayout Name)
  case "$INPUT_MODE" in
    *SCIM.ITABC*|*SCIM.Pinyin*) SHORT_LAYOUT="拼" ;;  # Simplified Chinese Pinyin
    *SCIM.WBH*)                  SHORT_LAYOUT="五" ;;  # Simplified Chinese Wubi
    *TCIM.Pinyin*)               SHORT_LAYOUT="拼" ;;  # Traditional Chinese Pinyin
    *TCIM.Cangjie*)              SHORT_LAYOUT="倉" ;;  # Traditional Chinese Cangjie
    *TCIM.Zhuyin*)               SHORT_LAYOUT="注" ;;  # Traditional Chinese Zhuyin/Bopomofo
    *Kotoeri.Japanese*)          SHORT_LAYOUT="JA" ;;  # Japanese Kotoeri
    *Korean*)                    SHORT_LAYOUT="KO" ;;  # Korean input method
    *) SHORT_LAYOUT="??" ;;
  esac
fi

sketchybar --set keyboard label="$SHORT_LAYOUT"
