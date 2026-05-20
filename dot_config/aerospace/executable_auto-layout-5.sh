#!/bin/bash
# 5+ window layout for AeroSpace: 2x2 grid with overflow stacked in the
# right v-container. Target tree: h{ v{W1, W2}, v{W3, W4, W5, ..., WN} }
# Same algorithm as auto-layout-4 — overflow accumulates in the right column.

LOG=/tmp/aerospace-layout.log
exec >>"$LOG" 2>&1
echo "---"
echo "$(date): auto-layout-5 START"

AEROSPACE=/opt/homebrew/bin/aerospace
STASH=L

ws=$("$AEROSPACE" list-workspaces --focused)
window_list=$("$AEROSPACE" list-windows --workspace "$ws" \
              --format "%{window-layout} %{window-id}" \
              | awk '$1 != "floating" {print $2}')
count=$(printf '%s\n' "$window_list" | grep -c .)

echo "  ws=$ws tileable=$count"

if [ "$count" -lt 5 ]; then
  echo "  skip: need 5+ tileable, got $count"
  exit 0
fi

i=0
while IFS= read -r wid; do
  windows[i]="$wid"
  i=$((i+1))
done <<EOF
$window_list
EOF

run() {
  if "$@" 2>&1; then :; else echo "    FAIL: $*"; fi
}

for w in "${windows[@]}"; do
  run "$AEROSPACE" move-node-to-workspace --window-id "$w" "$STASH"
done
sleep 0.1

for w in "${windows[@]}"; do
  run "$AEROSPACE" move-node-to-workspace --window-id "$w" "$ws"
done
sleep 0.1

run "$AEROSPACE" flatten-workspace-tree

# Pair W1+W2 vertically (focus W2, join-with left)
run "$AEROSPACE" focus --window-id "${windows[1]}"
run "$AEROSPACE" join-with --window-id "${windows[1]}" left

# Pair W3+W4 vertically (focus W4, join-with left)
run "$AEROSPACE" focus --window-id "${windows[3]}"
run "$AEROSPACE" join-with --window-id "${windows[3]}" left

# Overflow: W5..WN into the right v-container
i=4
while [ "$i" -lt "$count" ]; do
  run "$AEROSPACE" focus --window-id "${windows[i]}"
  run "$AEROSPACE" move left
  i=$((i+1))
done

run "$AEROSPACE" balance-sizes

echo "$(date): auto-layout-5 END"
