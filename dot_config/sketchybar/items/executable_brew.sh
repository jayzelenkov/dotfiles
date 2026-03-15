#!/bin/bash

BREW_ICON=$(printf '\xef\x86\xb2')  # U+F1B2 nf-fa-cube

brew=(
  icon="$BREW_ICON"
  label=?
  padding_right=10
  script="$PLUGIN_DIR/brew.sh"
)

sketchybar --add event brew_update \
           --add item brew right   \
           --set brew "${brew[@]}" \
           --subscribe brew brew_update
