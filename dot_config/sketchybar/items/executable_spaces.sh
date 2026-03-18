#!/bin/bash

# AeroSpace workspace indicators.
# icon = workspace number (highlighted yellow when active)
# label = Nerd Font app icons for all windows in that workspace (no highlight)
# Icons are populated at bar init via the 'routine' event on workspaces_service_mode.

sketchybar --add event aerospace_workspace_change
sketchybar --add event aerospace_service_mode_enabled_changed

NUM_FONT="$FONT:Bold:13.0"
NUM_HIGHLIGHT_FONT="$FONT:Bold:17.0"
ICON_FONT="$FONT:Regular:18.0"

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
                           icon="$workspace_id" \
                           icon.font="$NUM_FONT" \
                           icon.color=$LABEL_COLOR \
                           icon.highlight_color=0xffE5C07B \
                           icon.padding_left=4 \
                           icon.padding_right=2 \
                           label="" \
                           label.font="$ICON_FONT" \
                           label.color=$GREY \
                           label.padding_left=0 \
                           label.padding_right=6 \
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
               --subscribe workspaces_service_mode aerospace_service_mode_enabled_changed routine front_app_switched \
               --set       workspaces_service_mode \
                           background.drawing=off \
                           label.drawing=off \
                           label.highlight=on \
                           label.highlight_color=0xffE5C07B \
                           label.font="$NUM_HIGHLIGHT_FONT" \
                           label="[s]" \
                           label.padding_right=10 \
                           update_freq=4 \
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
