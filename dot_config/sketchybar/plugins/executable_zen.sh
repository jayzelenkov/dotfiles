#!/bin/bash

zen_on() {
  sketchybar --set apple.logo     drawing=off \
             --set calendar       icon.drawing=off \
             --set volume_icon    drawing=off \
             --set spotify.anchor drawing=off \
             --set spotify.play   updates=off \
             --set keyboard       drawing=off
}

zen_off() {
  sketchybar --set apple.logo     drawing=on \
             --set calendar       icon.drawing=on \
             --set volume_icon    drawing=on \
             --set spotify.play   updates=on \
             --set keyboard       drawing=on
}

if [ "$1" = "on" ]; then
  zen_on
elif [ "$1" = "off" ]; then
  zen_off
else
  if [ "$(sketchybar --query apple.logo | jq -r ".geometry.drawing")" = "on" ]; then
    zen_on
  else
    zen_off
  fi
fi
