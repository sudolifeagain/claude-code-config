#!/usr/bin/env bash
# Claude Code Config Installer
# Copies statusline script and skills to ~/.claude/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing Claude Code config to $CLAUDE_DIR ..."

# Ensure ~/.claude exists
mkdir -p "$CLAUDE_DIR"

# Install statusline script
if [ -f "$CLAUDE_DIR/statusline-command.sh" ]; then
  echo "  Overwriting: statusline-command.sh"
fi
cp "$SCRIPT_DIR/statusline-command.sh" "$CLAUDE_DIR/statusline-command.sh"
chmod +x "$CLAUDE_DIR/statusline-command.sh"
echo "  Installed: statusline-command.sh"

# Install skills
if [ -d "$SCRIPT_DIR/skills" ]; then
  for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    mkdir -p "$CLAUDE_DIR/skills/$skill_name"
    find "$skill_dir" -maxdepth 1 -type f -exec cp {} "$CLAUDE_DIR/skills/$skill_name/" \;
    echo "  Installed skill: $skill_name"
  done
fi

echo ""
echo "Done! Next steps:"
echo ""
echo "  Add the statusLine config to your ~/.claude/settings.json:"
echo ""
echo '    "statusLine": {'
echo '      "type": "command",'
echo '      "command": "bash ~/.claude/statusline-command.sh"'
echo '    }'
echo ""
echo "  Requirements: jq, curl, git"
