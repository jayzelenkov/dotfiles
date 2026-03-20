#!/usr/bin/env bash

source "$HOME/.config/sketchybar/colors.sh"

NUM_FONT="Hack Nerd Font Mono:Bold:13.0"
NUM_HIGHLIGHT_FONT="Hack Nerd Font Mono:Bold:17.0"

# Map app name → Nerd Font icon glyph
# Icons using 4-byte supplementary PUA (U+F0000+) are safe in Nerd Fonts v3.
# BMP PUA icons (U+E000-U+F8FF) are avoided for workspace labels to prevent ? rendering.
_ICON_ACTIVITY_MONITOR=$(printf '\xf3\xb0\xb4\x84')  # U+F0D04 nf-md-chart_areaspline_variant
_ICON_CALENDAR=$(printf '\xf3\xb0\x85\x96')          # U+F0156 nf-md-calendar
_ICON_DISCORD=$(printf '\xf3\xb0\x99\xa2')           # U+F0662 nf-md-discord
_ICON_GHOSTTY=$(printf '\xf3\xb0\x8a\xa0')           # U+F02A0 nf-md-ghost
_ICON_CHROME=$(printf '\xf3\xb0\x8a\xaf')            # U+F02AF nf-md-google_chrome
_ICON_MESSAGES=$(printf '\xf3\xb0\x8e\x86')          # U+F0386 nf-md-message
_ICON_MUSIC=$(printf '\xf3\xb0\x9d\x9a')             # U+F075A nf-md-music_note
_ICON_PREVIEW=$(printf '\xf3\xb0\x88\x88')           # U+F0208 nf-md-eye
_ICON_RAYCAST=$(printf '\xf3\xb0\x8d\x89')           # U+F0349 nf-md-magnify
_ICON_SAFARI=$(printf '\xf3\xb0\x96\x9f')            # U+F059F nf-md-web
_ICON_SPOTIFY=$(printf '\xf3\xb0\x9d\x9a')           # U+F075A nf-md-music_note (nf-md-spotify renders incorrectly in HNF Mono)
_ICON_SYSTEM=$(printf '\xf3\xb0\x92\x93')            # U+F0493 nf-md-cog
_ICON_TELEGRAM=$(printf '\xf3\xb0\x92\x8a')          # U+F048A nf-md-send
_ICON_TERMINAL=$(printf '\xf3\xb0\xa9\xb0')          # U+F0A70 nf-md-console_line
_ICON_DIAMOND=$(printf '\xf3\xb0\xae\x8a')           # U+F0B8A nf-md-diamond
_ICON_NOTES=$(printf '\xf3\xb0\xa7\xb0')             # U+F09F0 nf-md-note_text
_ICON_NUMBERS=$(printf '\xf3\xb0\x84\xa8')           # U+F0128 nf-md-chart_bar
_ICON_PAGES=$(printf '\xf3\xb0\x88\x99')             # U+F0219 nf-md-file_document
_ICON_WHATSAPP=$(printf '\xf3\xb0\x98\x87')          # U+F0607 nf-md-whatsapp
_ICON_XCODE=$(printf '\xf3\xb0\x8a\x95')             # U+F0295 nf-md-hammer
_ICON_LLAMA=$(printf '\xf3\xb1\x96\xbf')             # U+F15BF nf-md-horse (llama stand-in)
_ICON_TICK_TICK=$(printf '\xf3\xb0\x84\xb4')         # U+F0134 nf-md-checkbox_marked_circle_outline
_ICON_TRAY=$(printf '\xf3\xb0\x84\x9d')              # U+F011D nf-md-tray
_ICON_PHOTOS=$(printf '\xf3\xb0\x8b\xa9')            # U+F02E9 nf-md-image
_ICON_CURRENCY=$(printf '\xf3\xb0\x87\x81')          # U+F01C1 nf-md-currency_usd

# Apps to hide from workspace icon lists (overlays, non-focusable utilities)
SKIP_APPS="Wispr Flow"

skip_app() {
  case ":${SKIP_APPS}:" in *":$1:"*) return 0 ;; esac
  return 1
}

app_icon() {
  case "$1" in
    "1Password")                      echo "󰦝" ;;
    "Activity Monitor")               echo "$_ICON_ACTIVITY_MONITOR" ;;
    "Arc")                            echo "󰞍" ;;
    "Calendar")                       echo "$_ICON_CALENDAR" ;;
    "Claude")                         echo "󱙺" ;;
    "Code"|"Visual Studio Code")      echo "󰨞" ;;
    "Discord")                        echo "$_ICON_DISCORD" ;;
    "Finder")                         echo "󰀶" ;;
    "Ghostty")                        echo "$_ICON_GHOSTTY" ;;
    "Google Chrome")                  echo "$_ICON_CHROME" ;;
    "IINA")                           echo "󰕼" ;;
    "Messages")                       echo "$_ICON_MESSAGES" ;;
    "Music")                          echo "$_ICON_MUSIC" ;;
    "Notes")                          echo "$_ICON_NOTES" ;;
    "Notion")                         echo "󰎚" ;;
    "Numbers")                        echo "$_ICON_NUMBERS" ;;
    "Obsidian")                       echo "$_ICON_DIAMOND" ;;
    "Pages")                          echo "$_ICON_PAGES" ;;
    "Preview")                        echo "$_ICON_PREVIEW" ;;
    "Raycast")                        echo "$_ICON_RAYCAST" ;;
    "Safari")                         echo "$_ICON_SAFARI" ;;
    "Signal")                         echo "󰍡" ;;
    "Spotify")                        echo "$_ICON_SPOTIFY" ;;
    "System Preferences"|"System Settings") echo "$_ICON_SYSTEM" ;;
    "Telegram")                       echo "$_ICON_TELEGRAM" ;;
    "Terminal")                       echo "$_ICON_TERMINAL" ;;
    "Things")                         echo "$_ICON_TRAY" ;;
    "TickTick")                       echo "$_ICON_TICK_TICK" ;;
    "llamalife.co")                   echo "$_ICON_LLAMA" ;;
    "Photos")                         echo "$_ICON_PHOTOS" ;;
    "Copilot")                        echo "$_ICON_CURRENCY" ;;
    "WhatsApp")                       echo "$_ICON_WHATSAPP" ;;
    "Xcode")                          echo "$_ICON_XCODE" ;;
    "Zoom")                           echo "󰙯" ;;
    *)                                echo "󰘔" ;;
  esac
}

# Build deduplicated icon string for a single workspace using a pre-loaded map.
# $1 = workspace id, $2+ = "ws:app" entries from a full list-windows --all query
icons_for_workspace() {
  local ws_id="$1"
  local icons=""
  local seen=""
  while IFS=$'\t' read -r ws app; do
    [ "$ws" = "$ws_id" ] || continue
    [ -z "$app" ] && continue
    # Deduplicate by app name
    case ":${seen}:" in *":${app}:"*) continue ;; esac
    seen="${seen}:${app}"
    icons="${icons}$(app_icon "$app") "
  done < <(aerospace list-windows --all --format "%{workspace}	%{app-name}" 2>/dev/null)
  echo "${icons% }"
}

# Full refresh: update every workspace item in one pass (used at init via routine).
update_all_workspaces() {
  local focused
  focused=$(aerospace list-workspaces --focused 2>/dev/null | head -1)

  # Load all windows at once
  local all_windows
  all_windows=$(aerospace list-windows --all --format "%{workspace}	%{app-name}" 2>/dev/null)

  # For each known workspace, compute icons and update
  while IFS= read -r ws; do
    [ -z "$ws" ] && continue

    local icons=""
    local seen=""
    while IFS=$'\t' read -r w app; do
      [ "$w" = "$ws" ] || continue
      [ -z "$app" ] && continue
      skip_app "$app" && continue
      case ":${seen}:" in *":${app}:"*) continue ;; esac
      seen="${seen}:${app}"
      icons="${icons}$(app_icon "$app") "
    done <<< "$all_windows"
    icons="${icons% }"

    if [ "$ws" = "$focused" ]; then
      sketchybar --set "/space\\..*\\.$ws/" \
                       icon.highlight=on \
                       icon.font="$NUM_HIGHLIGHT_FONT" \
                       label="$icons" \
                       background.drawing=on \
                       background.color=0xffE5C07B
    else
      sketchybar --set "/space\\..*\\.$ws/" \
                       icon.highlight=off \
                       icon.font="$NUM_FONT" \
                       label="$icons" \
                       background.drawing=off
    fi
  done < <(aerospace list-workspaces --all 2>/dev/null)
}

# --- Event handlers ---

if [ "$SENDER" = "aerospace_service_mode_enabled_changed" ]; then
  if [ "$AEROSPACE_SERVICE_MODE_ENABLED" = "true" ]; then
    sketchybar --set workspaces_service_mode label.drawing=on
  else
    sketchybar --set workspaces_service_mode label.drawing=off
  fi
fi

# routine/forced: init refresh. front_app_switched: app opened, closed, or moved.
# Only workspaces_service_mode subscribes to these, so update_all_workspaces runs once.
if [ "$SENDER" = "routine" ] || [ "$SENDER" = "forced" ] || [ "$SENDER" = "front_app_switched" ]; then
  update_all_workspaces
fi

# Per-workspace update on workspace switch.
# $NAME = "space.<monitor>.<workspace_id>", $1 = this item's workspace_id
if [ "$SENDER" = "aerospace_workspace_change" ]; then
  workspace_id="$1"

  # Compute icons for this workspace
  icons=""
  seen=""
  while IFS=$'\t' read -r ws app; do
    [ "$ws" = "$workspace_id" ] || continue
    [ -z "$app" ] && continue
    skip_app "$app" && continue
    case ":${seen}:" in *":${app}:"*) continue ;; esac
    seen="${seen}:${app}"
    icons="${icons}$(app_icon "$app") "
  done < <(aerospace list-windows --all --format "%{workspace}	%{app-name}" 2>/dev/null)
  icons="${icons% }"

  if [ "$workspace_id" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" \
                     icon.highlight=on \
                     icon.font="$NUM_HIGHLIGHT_FONT" \
                     label="$icons" \
                     background.drawing=on \
                     background.color=0xffE5C07B
  else
    sketchybar --set "$NAME" \
                     icon.highlight=off \
                     icon.font="$NUM_FONT" \
                     label="$icons" \
                     background.drawing=off
  fi
fi
