#!/bin/bash

# AeroSpace workspace indicators — per-monitor brackets, simple number labels
sketchybar --add event aerospace_workspace_change
sketchybar --add event aerospace_service_mode_enabled_changed

LABEL_FONT="$FONT:Bold:13.0"
LABEL_HIGHLIGHT_FONT="$FONT:Bold:13.0"

create_workspace_bracket_for_monitor() {
  local monitor_id="$1"
  shift
  local monitor_workspaces=("$@")
  local monitor_count
  monitor_count=$(aerospace list-monitors | wc -l | tr -d ' ')

  if [ "$monitor_id" -eq 1 ]; then
    sketchybar --add item workspaces_spacer_left left \
               --set      workspaces_spacer_left \
                          width=4 \
                          background.drawing=off \
                          label.drawing=off
  fi

  for workspace_id in "${monitor_workspaces[@]}"; do
    sketchybar --add item "space.$monitor_id.$workspace_id" left \
               --subscribe "space.$monitor_id.$workspace_id" aerospace_workspace_change \
               --set       "space.$monitor_id.$workspace_id" \
                           background.drawing=off \
                           click_script="aerospace workspace $workspace_id" \
                           label="$workspace_id" \
                           label.width=30 \
                           label.font="$LABEL_FONT" \
                           label.color=$LABEL_COLOR \
                           label.highlight_color=0xffE5C07B \
                           script="$PLUGIN_DIR/aerospace.sh $workspace_id"
  done

  if [ "$monitor_id" -lt "$monitor_count" ]; then
    sketchybar --add item "workspaces_monitor_separator.$monitor_id" left \
               --set      "workspaces_monitor_separator.$monitor_id" \
                          background.drawing=off \
                          label.padding_left=-6 \
                          label="|"
  else
    sketchybar --add item workspaces_service_mode left \
               --subscribe workspaces_service_mode aerospace_service_mode_enabled_changed \
               --set       workspaces_service_mode \
                           background.drawing=off \
                           label.drawing=off \
                           label.highlight=on \
                           label.highlight_color=0xffE5C07B \
                           label.font="$LABEL_HIGHLIGHT_FONT" \
                           label="[s]" \
                           label.padding_right=10 \
                           script="$PLUGIN_DIR/aerospace.sh service_mode"

    sketchybar --add item workspaces_spacer_right left \
               --set      workspaces_spacer_right \
                          width=4 \
                          background.drawing=off \
                          label.drawing=off
  fi

  sketchybar --add bracket "spaces.$monitor_id" '/space\..*/'\
             --set         "spaces.$monitor_id" \
                           background.color=$BACKGROUND_1 \
                           background.border_color=$BACKGROUND_2 \
                           background.border_width=2 \
                           background.drawing=on \
                           background.corner_radius=9
}

monitor_ids=( $(aerospace list-monitors | awk '{print $1}') )

for monitor_id in "${monitor_ids[@]}"; do
  workspaces_for_monitor=( $(aerospace list-workspaces --monitor "$monitor_id") )
  create_workspace_bracket_for_monitor "$monitor_id" "${workspaces_for_monitor[@]}"
done
