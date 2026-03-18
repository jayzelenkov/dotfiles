#!/bin/bash

keyboard=(
  icon.drawing=off
  label.font="$FONT:Bold:16.0"
  script="$PLUGIN_DIR/keyboard.sh"
  click_script="osascript -e 'tell application \"System Events\" to keystroke \" \" using {control down, option down}'; sleep 0.3; $PLUGIN_DIR/keyboard.sh"
)

sketchybar --add event keyboard_layout_change  \
           --add item keyboard right           \
           --set keyboard "${keyboard[@]}"     \
           --subscribe keyboard keyboard_layout_change
