#!/bin/bash

calendar=(
  icon=cal
  icon.font="$FONT:Bold:12.0"
  icon.padding_right=12
  label.width=45
  label.align=right
  label.padding_left=3
  padding_left=15
  update_freq=1
  script="$PLUGIN_DIR/calendar.sh"
  click_script="$PLUGIN_DIR/zen.sh"
)

sketchybar --add item calendar right       \
           --set calendar "${calendar[@]}" \
           --subscribe calendar system_woke
