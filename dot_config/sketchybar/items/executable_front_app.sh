#!/bin/bash

FRONT_APP_SCRIPT='sketchybar --set $NAME label="$INFO"'

front_app=(
  script="$FRONT_APP_SCRIPT"
  icon.drawing=off
  label.color=$WHITE
  label.font="$FONT:Bold:12.0"
  associated_display=active
)

sketchybar --add item front_app left           \
           --set front_app "${front_app[@]}"   \
           --subscribe front_app front_app_switched
