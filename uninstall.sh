#!/usr/bin/env bash
# Claude Code Config Uninstaller
# Removes statusline script and skills installed by install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Uninstalling Claude Code config from $CLAUDE_DIR ..."

# Remove statusline script
if [ -f "$CLAUDE_DIR/statusline-command.sh" ]; then
  rm "$CLAUDE_DIR/statusline-command.sh"
  echo "  Removed: statusline-command.sh"
else
  echo "  Skipped: statusline-command.sh (not found)"
fi

# Remove skills (derived from repo contents, not hardcoded)
if [ -d "$SCRIPT_DIR/skills" ]; then
  for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    if [ -d "$CLAUDE_DIR/skills/$skill_name" ]; then
      rm -rf "$CLAUDE_DIR/skills/$skill_name"
      echo "  Removed skill: $skill_name"
    else
      echo "  Skipped skill: $skill_name (not found)"
    fi
  done
fi

echo ""
echo "Done! Don't forget to:"
echo "  - Remove the \"statusLine\" entry from ~/.claude/settings.json"
