#!/bin/bash

update() {
  if [ "$(echo "$INFO" | jq -r '.["Player State"]')" = "Playing" ]; then
    TRACK="$(echo "$INFO"  | jq -r .Name   | sed 's/.\{38\}/&…/' | head -c 40)"
    ARTIST="$(echo "$INFO" | jq -r .Artist | sed 's/.\{28\}/&…/' | head -c 30)"
    if [ -n "$ARTIST" ]; then
      DISPLAY="$TRACK — $ARTIST"
    else
      DISPLAY="$TRACK"
    fi
    sketchybar --set spotify drawing=on label="$DISPLAY"
  else
    sketchybar --set spotify drawing=off label=""
  fi
}

case "$SENDER" in
  "system_woke") update ;;
  *)             update ;;
esac
