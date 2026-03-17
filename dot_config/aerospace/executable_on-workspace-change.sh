#!/usr/bin/env bash

# Notify Sketchybar about workspace change
/opt/homebrew/bin/sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$AEROSPACE_FOCUSED_WORKSPACE"

# Move Wispr Flow overlay windows to the focused workspace so they remain usable
# regardless of which workspace is active.
/opt/homebrew/bin/aerospace list-windows --all --json \
    | /opt/homebrew/bin/jq -r '.[] | select(.["app-name"] == "Wispr Flow") | .["window-id"]' \
    | xargs -I{} /opt/homebrew/bin/aerospace move-node-to-workspace --window-id {} "$AEROSPACE_FOCUSED_WORKSPACE"
