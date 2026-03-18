#!/bin/bash

# All icons use printf hex sequences for bash 3.x compatibility
# (macOS /bin/bash is 3.2 which doesn't support $'\uXXXX')

# General Icons
export LOADING=$(printf '\xef\x84\x90')          # U+F110 nf-fa-spinner
export APPLE=$(printf '\xef\x85\xb9')            # U+F179 nf-fa-apple
export PREFERENCES=$(printf '\xef\x80\x93')      # U+F013 nf-fa-cog
export ACTIVITY=$(printf '\xef\x80\x82')         # U+F002 nf-fa-search
export LOCK=$(printf '\xef\x80\xa3')             # U+F023 nf-fa-lock
export BELL=$(printf '\xef\x83\xb3')             # U+F0F3 nf-fa-bell
export BELL_DOT=$(printf '\xef\x87\xb6')         # U+F1F6 nf-fa-bell-slash

# Git Icons
export GIT_ISSUE=$(printf '\xef\x86\xb3')        # U+F1B3 nf-fa-bug
export GIT_DISCUSSION=$(printf '\xef\x82\x86')   # U+F086 nf-fa-comments
export GIT_PULL_REQUEST=$(printf '\xef\x84\xa6') # U+F126 nf-fa-code-fork
export GIT_COMMIT=$(printf '\xef\x90\x97')       # U+F417 nf-oct-git-commit
export GIT_INDICATOR=$(printf '\xef\x84\x91')    # U+F111 nf-fa-circle

# Spotify Icons
export SPOTIFY_BACK=$(printf '\xef\x81\x8a')     # U+F04A nf-fa-backward
export SPOTIFY_PLAY_PAUSE=$(printf '\xef\x81\x8b') # U+F04B nf-fa-play
export SPOTIFY_NEXT=$(printf '\xef\x81\x8e')     # U+F04E nf-fa-forward
export SPOTIFY_SHUFFLE=$(printf '\xef\x81\xb4')  # U+F074 nf-fa-random
export SPOTIFY_REPEAT=$(printf '\xef\x80\x9e')   # U+F01E nf-fa-repeat

# Layout Icons
export YABAI_STACK=$(printf '\xef\x83\x89')      # U+F0C9 nf-fa-bars
export YABAI_FULLSCREEN_ZOOM=$(printf '\xef\x81\xa5') # U+F065 nf-fa-arrows-alt
export YABAI_PARENT_ZOOM=$(printf '\xef\x90\xa4') # U+F424 nf-fa-maximize
export YABAI_FLOAT=$(printf '\xef\x8b\x90')      # U+F2D0 nf-fa-window-restore
export YABAI_GRID=$(printf '\xef\x80\x8a')       # U+F00A nf-fa-th

# Battery Icons
export BATTERY_100=$(printf '\xef\x89\x80')      # U+F240 nf-fa-battery-full
export BATTERY_75=$(printf '\xef\x89\x81')       # U+F241 nf-fa-battery-three-quarters
export BATTERY_50=$(printf '\xef\x89\x82')       # U+F242 nf-fa-battery-half
export BATTERY_25=$(printf '\xef\x89\x83')       # U+F243 nf-fa-battery-quarter
export BATTERY_0=$(printf '\xef\x89\x84')        # U+F244 nf-fa-battery-empty
export BATTERY_CHARGING=$(printf '\xef\x83\xa7') # U+F0E7 nf-fa-bolt

# Volume Icons (nf-md-* supplementary PUA — safe in Nerd Fonts v3)
export VOLUME_100=$(printf '\xf3\xb0\x95\xbe')  # U+F057E nf-md-volume-high
export VOLUME_66=$(printf '\xf3\xb0\x96\x80')   # U+F0580 nf-md-volume-medium
export VOLUME_33=$(printf '\xf3\xb0\x95\xbd')   # U+F057D nf-md-volume-low
export VOLUME_10=$(printf '\xf3\xb0\x95\xbd')   # U+F057D nf-md-volume-low
export VOLUME_0=$(printf '\xf3\xb0\x96\x81')    # U+F0581 nf-md-volume-mute
