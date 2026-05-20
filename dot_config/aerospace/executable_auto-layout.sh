#!/bin/bash
# Dispatcher: count non-floating windows in the focused workspace
# and apply the appropriate auto-layout.
#
# Includes lock-based debouncing to avoid parallel runs when multiple
# on-window-detected callbacks fire close together.

LOG=/tmp/aerospace-layout.log
exec >>"$LOG" 2>&1

AEROSPACE=/opt/homebrew/bin/aerospace

# Debounce: if another run started within the last 2 seconds, bail.
LOCK=/tmp/aerospace-layout.lock
now=$(date +%s)
if [ -f "$LOCK" ]; then
  last=$(stat -f %m "$LOCK" 2>/dev/null || echo 0)
  if [ "$((now - last))" -lt 2 ]; then
    echo "$(date): dispatch skipped (lock <2s old)"
    exit 0
  fi
fi
touch "$LOCK"

ws=$("$AEROSPACE" list-workspaces --focused)

# Count windows whose layout is NOT 'floating'
count=$("$AEROSPACE" list-windows --workspace "$ws" --format "%{window-layout}" \
        | grep -v "^floating$" | grep -c .)

echo "$(date): dispatch ws=$ws tileable=$count"

case "$count" in
  3) "$HOME/.config/aerospace/auto-layout-3.sh" ;;
  4) "$HOME/.config/aerospace/auto-layout-4.sh" ;;
  *)
    if [ "$count" -ge 5 ]; then
      "$HOME/.config/aerospace/auto-layout-5.sh"
    else
      echo "  skip: count=$count (need 3+)"
    fi
    ;;
esac
