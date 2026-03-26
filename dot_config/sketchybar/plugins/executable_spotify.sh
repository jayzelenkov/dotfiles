#!/bin/bash

PLAY_ICON=$(printf '\xf3\xb0\x90\x8a')   # U+F040A nf-md-play
PAUSE_ICON=$(printf '\xf3\xb0\x8f\xa4')  # U+F03E4 nf-md-pause
LABEL_STATE="/tmp/sketchybar_spotify_label"
HOVER_MARKER="/tmp/sketchybar_spotify_hover"

# Handle toggle from click_script (runs outside the event loop)
if [ "$1" = "toggle_label" ]; then
  if [ -f "$LABEL_STATE" ]; then
    rm -f "$LABEL_STATE"
    sketchybar --set spotify.anchor label=""
  else
    touch "$LABEL_STATE"
    # Rebuild the label from current Spotify state
    if pgrep -xq "Spotify"; then
      TRACK="$(osascript -e 'tell application "Spotify" to get name of current track' 2>/dev/null)"
      ARTIST="$(osascript -e 'tell application "Spotify" to get artist of current track' 2>/dev/null)"
      if [ -n "$ARTIST" ]; then
        sketchybar --set spotify.anchor label="$TRACK — $ARTIST"
      else
        sketchybar --set spotify.anchor label="$TRACK"
      fi
    fi
  fi
  exit 0
fi

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

    # Respect contracted/expanded state for bar label
    if [ -f "$LABEL_STATE" ]; then
      BAR_LABEL="$DISPLAY"
    else
      BAR_LABEL=""
    fi

    sketchybar -m --set spotify.title label="$TRACK"          \
                  --set spotify.artist label="$ARTIST"         \
                  --set spotify.album label="$ALBUM"           \
                  --set spotify.cover background.image="/tmp/cover.jpg" \
                                     background.color=0x00000000       \
                  --set spotify.play icon="$PAUSE_ICON"        \
                  --set spotify.anchor drawing=on label="$BAR_LABEL"
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

check_running() {
  if ! pgrep -xq "Spotify"; then
    sketchybar -m --set spotify.anchor drawing=off popup.drawing=off
  fi
}

# Popup child hover tracking — keeps popup alive while mouse is inside
if [ "$NAME" != "spotify.anchor" ]; then
  case "$SENDER" in
    "mouse.entered")
      touch "$HOVER_MARKER"
      exit 0
      ;;
    "mouse.exited")
      rm -f "$HOVER_MARKER"
      ( sleep 0.5
        [ ! -f "$HOVER_MARKER" ] && sketchybar --set spotify.anchor popup.drawing=off
      ) &
      exit 0
      ;;
  esac
fi

case "$SENDER" in
  "mouse.clicked") mouse_clicked ;;
  "mouse.entered")
    touch "$HOVER_MARKER"
    popup on
    ;;
  "mouse.exited")
    rm -f "$HOVER_MARKER"
    ( sleep 0.5
      [ ! -f "$HOVER_MARKER" ] && sketchybar --set spotify.anchor popup.drawing=off
    ) &
    ;;
  "mouse.exited.global")
    rm -f "$HOVER_MARKER"
    popup off
    ;;
  "front_app_switched")
    rm -f "$HOVER_MARKER"
    popup off
    check_running
    ;;
  "routine") check_running ;;
  *) update ;;
esac
