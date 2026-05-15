#!/usr/bin/env bash
# Re-zip the decision-brief skill folder for upload to Claude Desktop and claude.ai.
set -euo pipefail
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SKILL_DIR")"
ZIP_PATH="$PARENT_DIR/decision-brief.zip"

cd "$PARENT_DIR"
rm -f "$ZIP_PATH"
zip -r "$ZIP_PATH" decision-brief \
  -x '*.DS_Store' \
  -x 'decision-brief/repackage.sh'

echo "✓ Re-packaged: $ZIP_PATH"
echo "  Size: $(du -h "$ZIP_PATH" | cut -f1)"
echo ""
echo "Next: open Claude Desktop → Customize → Skills → + Create skill → upload the ZIP."
echo "For iOS sync, upload the same ZIP at https://claude.ai → Customize → Skills."
