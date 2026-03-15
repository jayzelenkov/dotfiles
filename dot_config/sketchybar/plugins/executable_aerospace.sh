#!/usr/bin/env bash

# $1 is the workspace ID this item represents
WORKSPACE_ID="$1"

update() {
  SELECTED=false
  [ "$FOCUSED_WORKSPACE" = "$WORKSPACE_ID" ] && SELECTED=true

  WIDTH="dynamic"
  [ "$SELECTED" = "true" ] && WIDTH="0"

  # Get app icons for this workspace using sketchybar-app-font
  APPS=$(aerospace list-windows --workspace "$WORKSPACE_ID" 2>/dev/null \
    | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

  icon_strip=" "
  if [ -n "$APPS" ]; then
    while IFS= read -r app; do
      icon_strip+=" $($HOME/.config/sketchybar/plugins/icon_map.sh "$app")"
    done <<< "$APPS"
  fi

  sketchybar --animate tanh 20 \
             --set "$NAME"     \
             icon.highlight="$SELECTED" \
             label.width="$WIDTH"       \
             label="$icon_strip"        \
             label.drawing=on
}

update
