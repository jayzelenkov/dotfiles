#!/bin/bash

POPUP_OFF="sketchybar --set apple.logo popup.drawing=off"

apple_logo=(
  icon=$APPLE
  icon.font="$FONT:Bold:16.0"
  icon.color=0xffE5C07B
  padding_left=8
  padding_right=15
  y_offset=2
  label.drawing=off
  script="$PLUGIN_DIR/apple.sh"
)

apple_prefs=(
  icon=$PREFERENCES
  label="Preferences"
  click_script="open -a 'System Settings'; $POPUP_OFF"
)

apple_activity=(
  icon=$ACTIVITY
  label="Activity"
  click_script="open -a 'Activity Monitor'; $POPUP_OFF"
)

apple_lock=(
  icon=$LOCK
  label="Lock Screen"
  click_script="osascript -e 'tell application \"System Events\" to keystroke \"q\" using {control down, command down}'; $POPUP_OFF"
)

sketchybar --add item apple.logo left                  \
           --set apple.logo "${apple_logo[@]}"         \
           --subscribe apple.logo mouse.clicked        \
                       mouse.exited.global             \
                                                       \
           --add item apple.prefs popup.apple.logo     \
           --set apple.prefs "${apple_prefs[@]}"       \
                                                       \
           --add item apple.activity popup.apple.logo  \
           --set apple.activity "${apple_activity[@]}" \
                                                       \
           --add item apple.lock popup.apple.logo      \
           --set apple.lock "${apple_lock[@]}"
