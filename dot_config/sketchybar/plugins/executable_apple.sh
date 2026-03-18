#!/bin/bash

case "$SENDER" in
  "mouse.exited.global")
    sketchybar --set "$NAME" popup.drawing=off
    ;;
  "mouse.clicked")
    sketchybar --set "$NAME" popup.drawing=toggle
    ;;
esac
