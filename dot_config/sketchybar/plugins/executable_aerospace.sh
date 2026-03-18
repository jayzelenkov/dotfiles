#!/usr/bin/env bash

source "$HOME/.config/sketchybar/colors.sh"

LABEL_FONT="Hack Nerd Font Mono:Bold:13.0"
LABEL_HIGHLIGHT_FONT="Hack Nerd Font Mono:Bold:17.0"

if [ "$SENDER" = "aerospace_service_mode_enabled_changed" ]; then
  if [ "$AEROSPACE_SERVICE_MODE_ENABLED" = "true" ]; then
    sketchybar --set workspaces_service_mode label.drawing=on
  else
    sketchybar --set workspaces_service_mode label.drawing=off
  fi
fi

if [ "$SENDER" = "aerospace_workspace_change" ]; then
  if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" \
                     label.highlight=on \
                     label.font="$LABEL_HIGHLIGHT_FONT"
  else
    sketchybar --set "$NAME" \
                     label.highlight=off \
                     label.font="$LABEL_FONT"
  fi
fi
