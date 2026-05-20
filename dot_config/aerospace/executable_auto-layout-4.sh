#!/bin/bash
# 4-window 2x2 grid for AeroSpace.
# Target tree: h{ v{W1, W2}, v{W3, W4} }
#
# Algorithm (validated working):
#   1. Stash all tileable windows on workspace "L"
#   2. Move them back in deterministic order → flat h-row
#   3. flatten-workspace-tree
#   4. focus W2, join-with --window-id W2 left → creates v{W1, W2}
#   5. focus W4, join-with --window-id W4 left → creates v{W3, W4}
#   6. balance-sizes
#
# Opposite-orientation normalization auto-flips the h-containers created by
# join-with into vertical, so no explicit `layout v_tiles` is needed.

LOG=/tmp/aerospace-layout.log
exec >>"$LOG" 2>&1
echo "---"
echo "$(date): auto-layout-4 START"

AEROSPACE=/opt/homebrew/bin/aerospace
STASH=L

ws=$("$AEROSPACE" list-workspaces --focused)
window_list=$("$AEROSPACE" list-windows --workspace "$ws" \
              --format "%{window-layout} %{window-id}" \
              | awk '$1 != "floating" {print $2}')
count=$(printf '%s\n' "$window_list" | grep -c .)

echo "  ws=$ws tileable=$count"

if [ "$count" -lt 4 ]; then
  echo "  skip: need 4+ tileable, got $count"
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

# Stash all windows on workspace L (clean slate, ordering reset)
for w in "${windows[@]}"; do
  run "$AEROSPACE" move-node-to-workspace --window-id "$w" "$STASH"
done
sleep 0.1

# Move back to source workspace in deterministic order
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

# Overflow: W5+ move into right v-container
i=4
while [ "$i" -lt "$count" ]; do
  run "$AEROSPACE" focus --window-id "${windows[i]}"
  run "$AEROSPACE" move left
  i=$((i+1))
done

run "$AEROSPACE" balance-sizes

echo "$(date): auto-layout-4 END"
