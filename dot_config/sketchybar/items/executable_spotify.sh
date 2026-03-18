#!/bin/bash

SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"
SPOTIFY_ICON=$(printf '\xef\x86\xbc')  # U+F1BC nf-fa-spotify

spotify=(
  script="$PLUGIN_DIR/spotify.sh"
  click_script="osascript -e 'tell application \"Spotify\" to playpause'"
  icon="$SPOTIFY_ICON"
  icon.font="$FONT:Regular:18.0"
  icon.color=$GREEN
  icon.padding_right=6
  label.font="$FONT:Regular:12.0"
  label.max_chars=40
  label=""
  drawing=off
  padding_left=8
  padding_right=8
)

sketchybar --add event spotify_change $SPOTIFY_EVENT  \
           --add item spotify center                   \
           --set spotify "${spotify[@]}"               \
           --subscribe spotify spotify_change system_woke
