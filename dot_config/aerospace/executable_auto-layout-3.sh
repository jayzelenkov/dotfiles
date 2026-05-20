#!/bin/bash
# 3-window layout for AeroSpace:
#   - W1 fills top-left 25%
#   - W2 fills bottom-left 25%
#   - W3 fills the entire right 50%
#
# Target tree: h{ v{W1, W2}, W3 }
# Algorithm: stash on "L" → reinsert → flatten → focus W2, join-with left.
# (join-with-left on W2 joins W1+W2; opposite-orientation normalization
# flips the new h-container into v, giving us the left vertical pair.)

LOG=/tmp/aerospace-layout.log
exec >>"$LOG" 2>&1
echo "---"
echo "$(date): auto-layout-3 START"

AEROSPACE=/opt/homebrew/bin/aerospace
STASH=L

ws=$("$AEROSPACE" list-workspaces --focused)
window_list=$("$AEROSPACE" list-windows --workspace "$ws" \
              --format "%{window-layout} %{window-id}" \
              | awk '$1 != "floating" {print $2}')
count=$(printf '%s\n' "$window_list" | grep -c .)

echo "  ws=$ws tileable=$count"

if [ "$count" -lt 3 ]; then
  echo "  skip: need 3+ tileable, got $count"
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

# Pair W1+W2 vertically on the left (focus W2, join-with left)
run "$AEROSPACE" focus --window-id "${windows[1]}"
run "$AEROSPACE" join-with --window-id "${windows[1]}" left

# Overflow: W4+ would go into the right column alongside W3.
# Since W3 is a leaf, joining first then moving overflow there.
i=3
while [ "$i" -lt "$count" ]; do
  run "$AEROSPACE" focus --window-id "${windows[i]}"
  run "$AEROSPACE" move left
  i=$((i+1))
done

run "$AEROSPACE" balance-sizes

echo "$(date): auto-layout-3 END"
