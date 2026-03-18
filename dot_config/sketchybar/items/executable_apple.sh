#!/bin/bash

POPUP_OFF="sketchybar --set apple.logo popup.drawing=off"

apple_logo=(
  icon=$APPLE
  icon.font="$FONT:Bold:24.0"
  icon.color=0xffE5C07B
  padding_left=8
  padding_right=10
  y_offset=1
  label.drawing=off
  script="$PLUGIN_DIR/apple.sh"
  popup.background.border_color=$GREEN
  popup.background.border_width=2
  popup.background.corner_radius=14
)

apple_prefs=(
  icon=$PREFERENCES
  icon.font="$FONT:Bold:17.0"
  icon.color=$POPUP_BACKGROUND_COLOR
  icon.background.drawing=on
  icon.background.color=$WHITE
  icon.background.corner_radius=14
  icon.padding_left=13
  icon.padding_right=9
  label="Preferences"
  label.font="$FONT:Bold:14.0"
  label.padding_left=4
  label.padding_right=16
  padding_left=8
  padding_right=8
  background.height=48
  click_script="open -a 'System Settings'; $POPUP_OFF"
)

apple_activity=(
  icon=$ACTIVITY
  icon.font="$FONT:Bold:17.0"
  icon.color=$POPUP_BACKGROUND_COLOR
  icon.background.drawing=on
  icon.background.color=$WHITE
  icon.background.corner_radius=14
  icon.padding_left=13
  icon.padding_right=9
  label="Activity"
  label.font="$FONT:Bold:14.0"
  label.padding_left=4
  label.padding_right=16
  padding_left=8
  padding_right=8
  background.height=48
  click_script="open -a 'Activity Monitor'; $POPUP_OFF"
)

apple_lock=(
  icon=$LOCK
  icon.font="$FONT:Bold:17.0"
  icon.color=$POPUP_BACKGROUND_COLOR
  icon.background.drawing=on
  icon.background.color=$WHITE
  icon.background.corner_radius=14
  icon.padding_left=13
  icon.padding_right=9
  label="Lock Screen"
  label.font="$FONT:Bold:14.0"
  label.padding_left=4
  label.padding_right=16
  padding_left=8
  padding_right=8
  background.height=48
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
