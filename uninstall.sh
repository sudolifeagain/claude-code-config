#!/usr/bin/env bash
# Claude Code Config Uninstaller
# Removes statusline script and skills installed by install.sh

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"

echo "Uninstalling Claude Code config from $CLAUDE_DIR ..."

# Remove statusline script
if [ -f "$CLAUDE_DIR/statusline-command.sh" ]; then
  rm "$CLAUDE_DIR/statusline-command.sh"
  echo "  Removed: statusline-command.sh"
else
  echo "  Skipped: statusline-command.sh (not found)"
fi

# Remove skills
for skill in copilot-review review-pr; do
  if [ -d "$CLAUDE_DIR/skills/$skill" ]; then
    rm -rf "$CLAUDE_DIR/skills/$skill"
    echo "  Removed skill: $skill"
  else
    echo "  Skipped skill: $skill (not found)"
  fi
done

echo ""
echo "Done! Don't forget to:"
echo "  - Remove the \"statusLine\" entry from ~/.claude/settings.json"
