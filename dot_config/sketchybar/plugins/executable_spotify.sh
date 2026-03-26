#!/bin/bash

PLAY_ICON=$(printf '\xf3\xb0\x90\x8a')   # U+F040A nf-md-play
PAUSE_ICON=$(printf '\xf3\xb0\x8f\xa4')  # U+F03E4 nf-md-pause

update() {
  # Determine play state: use event JSON if available, otherwise query directly
  if [ -n "$INFO" ]; then
    STATE="$(echo "$INFO" | jq -r '.["Player State"]')"
  elif pgrep -xq "Spotify"; then
    STATE="$(osascript -e 'tell application "Spotify" to get player state' 2>/dev/null)"
    # osascript returns lowercase; normalize
    [ "$STATE" = "playing" ] && STATE="Playing"
  else
    STATE="Stopped"
  fi

  if [ "$STATE" = "Playing" ]; then
    if [ -n "$INFO" ]; then
      TRACK="$(echo "$INFO" | jq -r .Name)"
      ARTIST="$(echo "$INFO" | jq -r .Artist)"
      ALBUM="$(echo "$INFO" | jq -r .Album)"
    else
      TRACK="$(osascript -e 'tell application "Spotify" to get name of current track')"
      ARTIST="$(osascript -e 'tell application "Spotify" to get artist of current track')"
      ALBUM="$(osascript -e 'tell application "Spotify" to get album of current track')"
    fi
    COVER=$(osascript -e 'tell application "Spotify" to get artwork url of current track')

    curl -s --max-time 20 "$COVER" -o /tmp/cover.jpg

    if [ -n "$ARTIST" ]; then
      DISPLAY="$TRACK — $ARTIST"
    else
      DISPLAY="$TRACK"
    fi

    sketchybar -m --set spotify.title label="$TRACK"          \
                  --set spotify.artist label="$ARTIST"         \
                  --set spotify.album label="$ALBUM"           \
                  --set spotify.cover background.image="/tmp/cover.jpg" \
                                     background.color=0x00000000       \
                  --set spotify.play icon="$PAUSE_ICON"        \
                  --set spotify.anchor drawing=on label="$DISPLAY"
  else
    if pgrep -xq "Spotify"; then
      sketchybar -m --set spotify.anchor drawing=on label="" \
                    --set spotify.play icon="$PLAY_ICON"
    else
      sketchybar -m --set spotify.anchor drawing=off popup.drawing=off
    fi
  fi
}

mouse_clicked() {
  case "$NAME" in
    "spotify.back") osascript -e 'tell application "Spotify" to play previous track' ;;
    "spotify.play") osascript -e 'tell application "Spotify" to playpause' ;;
    "spotify.next") osascript -e 'tell application "Spotify" to play next track' ;;
    "spotify.open")
      ws=$(aerospace list-windows --all --format "%{workspace}	%{app-name}" 2>/dev/null \
           | awk -F'\t' '$2=="Spotify"{print $1; exit}')
      if [ -n "$ws" ]; then
        aerospace workspace "$ws"
      else
        open -a Spotify
      fi
      sketchybar --set spotify.anchor popup.drawing=off
      ;;
  esac
}

popup() {
  sketchybar --set spotify.anchor popup.drawing=$1
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked ;;
  "mouse.entered") popup on ;;
  "mouse.exited"|"mouse.exited.global") popup off ;;
  *) update ;;
esac
