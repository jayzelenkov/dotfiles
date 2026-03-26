#!/bin/bash

SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"
MUSIC_ICON=$(printf '\xf3\xb0\x9d\x9a')  # U+F075A nf-md-music_note
PREV_ICON=$(printf '\xf3\xb0\x92\xae')   # U+F04AE nf-md-skip_previous
PLAY_ICON=$(printf '\xf3\xb0\x90\x8a')   # U+F040A nf-md-play
PAUSE_ICON=$(printf '\xf3\xb0\x8f\xa4')  # U+F03E4 nf-md-pause
NEXT_ICON=$(printf '\xf3\xb0\x92\xad')   # U+F04AD nf-md-skip_next

spotify_anchor=(
  script="$PLUGIN_DIR/spotify.sh"
  click_script="osascript -e 'tell application \"Spotify\" to playpause'"
  popup.horizontal=on
  popup.align=center
  popup.height=120
  icon="$MUSIC_ICON"
  icon.font="$FONT:Regular:16.0"
  icon.color=$GREY
  icon.padding_right=4
  label.font="$FONT:Regular:12.0"
  label.max_chars=30
  label=""
  drawing=off
  padding_left=8
  padding_right=0
)

spotify_cover=(
  script="$PLUGIN_DIR/spotify.sh"
  label.drawing=off
  icon.drawing=off
  padding_left=12
  padding_right=10
  background.image.scale=0.15
  background.image.drawing=on
  background.drawing=on
  background.color=0x00000000
)

spotify_title=(
  icon.drawing=off
  padding_left=0
  padding_right=0
  width=0
  label.font="$FONT:Bold:13.0"
  label.color=$WHITE
  label.max_chars=25
  label.scroll_duration=200
  scroll_texts=on
  y_offset=35
)

spotify_artist=(
  icon.drawing=off
  padding_left=0
  padding_right=0
  width=0
  label.font="$FONT:Regular:11.0"
  label.color=$GREY
  label.max_chars=25
  label.scroll_duration=200
  scroll_texts=on
  y_offset=12
)

spotify_album=(
  icon.drawing=off
  padding_left=0
  padding_right=0
  width=0
  label.font="$FONT:Regular:10.0"
  label.color=$GREY
  label.max_chars=25
  label.scroll_duration=200
  scroll_texts=on
  y_offset=-8
)

spotify_back=(
  icon="$PREV_ICON"
  icon.font="$FONT:Regular:16.0"
  icon.color=$WHITE
  icon.padding_left=5
  icon.padding_right=5
  label.drawing=off
  script="$PLUGIN_DIR/spotify.sh"
  y_offset=-38
)

spotify_play=(
  icon="$PLAY_ICON"
  icon.font="$FONT:Regular:16.0"
  icon.color=$WHITE
  icon.padding_left=8
  icon.padding_right=8
  background.height=30
  background.corner_radius=15
  background.color=$BACKGROUND_2
  background.border_color=$GREY
  background.border_width=1
  background.drawing=on
  width=40
  align=center
  label.drawing=off
  script="$PLUGIN_DIR/spotify.sh"
  y_offset=-38
)

spotify_next=(
  icon="$NEXT_ICON"
  icon.font="$FONT:Regular:16.0"
  icon.color=$WHITE
  icon.padding_left=5
  icon.padding_right=5
  label.drawing=off
  script="$PLUGIN_DIR/spotify.sh"
  y_offset=-38
)

spotify_open=(
  icon="$MUSIC_ICON"
  icon.font="$FONT:Regular:14.0"
  icon.color=$GREEN
  icon.padding_left=20
  icon.padding_right=10
  label.drawing=off
  script="$PLUGIN_DIR/spotify.sh"
  y_offset=-38
)

sketchybar --add event spotify_change $SPOTIFY_EVENT                       \
                                                                           \
           --add item spotify.anchor right                                 \
           --set spotify.anchor "${spotify_anchor[@]}"                     \
           --subscribe spotify.anchor spotify_change system_woke           \
                                      mouse.entered mouse.exited           \
                                      mouse.exited.global                  \
                                                                           \
           --add item spotify.cover popup.spotify.anchor                   \
           --set spotify.cover "${spotify_cover[@]}"                       \
                                                                           \
           --add item spotify.title popup.spotify.anchor                   \
           --set spotify.title "${spotify_title[@]}"                       \
                                                                           \
           --add item spotify.artist popup.spotify.anchor                  \
           --set spotify.artist "${spotify_artist[@]}"                     \
                                                                           \
           --add item spotify.album popup.spotify.anchor                   \
           --set spotify.album "${spotify_album[@]}"                       \
                                                                           \
           --add item spotify.back popup.spotify.anchor                    \
           --set spotify.back "${spotify_back[@]}"                         \
           --subscribe spotify.back mouse.clicked                          \
                                                                           \
           --add item spotify.play popup.spotify.anchor                    \
           --set spotify.play "${spotify_play[@]}"                         \
           --subscribe spotify.play mouse.clicked                          \
                                                                           \
           --add item spotify.next popup.spotify.anchor                    \
           --set spotify.next "${spotify_next[@]}"                         \
           --subscribe spotify.next mouse.clicked                          \
                                                                           \
           --add item spotify.open popup.spotify.anchor                    \
           --set spotify.open "${spotify_open[@]}"                         \
           --subscribe spotify.open mouse.clicked                          \
                                                                           \
           --add item spotify.spacer popup.spotify.anchor                  \
           --set spotify.spacer width=5
