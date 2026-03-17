# Claude Code Config

Custom configuration for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — Anthropic's official CLI for Claude.

## Features

### Status Line

A [robbyrussell](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes#robbyrussell)-inspired status line.

**Displayed information:** project directory, git branch (+ dirty flag), model name, context window usage, session cost, 5h / 7d usage quota with countdown.

**Key features:**
- Worktree-aware: shows the original project name even when running with `claude -w`
- Smart branch abbreviation: `worktree-*` → `wt:`, `feature/*` → `f/`, `fix/*` → `x/`
- Color-coded usage quotas: green (<50%), yellow (50-79%), red (>=80%)
- Quota data cached for 5 minutes (10 min backoff on failure)
- Cross-platform: works on Windows (Git Bash), Linux, and macOS

### Custom Skills

- **`/review-pr`** — Thorough code review posted as a PR comment
- **`/copilot-review`** — Request GitHub Copilot review on a PR

## Installation

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- `jq` — JSON processor (for status line)
- `curl` — HTTP client (for usage quota fetch)
- `git` — for branch/worktree detection

### Quick Install

```bash
git clone https://github.com/sudolifeagain/claude-code-config.git
cd claude-code-config
bash install.sh
```

### Manual Install

1. Copy the status line script:

```bash
cp statusline-command.sh ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
```

2. Add to your `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-command.sh"
  }
}
```

3. (Optional) Install skills:

```bash
cp -r skills/* ~/.claude/skills/
```

## Uninstall

```bash
cd claude-code-config
bash uninstall.sh
```

Then remove the `"statusLine"` entry from `~/.claude/settings.json`.

## File Structure

```
claude-code-config/
├── README.md
├── LICENSE
├── install.sh                  # Installer script
├── uninstall.sh                # Uninstaller script
├── settings.example.json       # Example settings.json
├── statusline-command.sh       # Status line script
└── skills/
    ├── copilot-review/SKILL.md # /copilot-review skill
    └── review-pr/SKILL.md      # /review-pr skill
```

## License

MIT

---

# Claude Code Config (日本語)

[Claude Code](https://docs.anthropic.com/en/docs/claude-code)（Anthropic公式CLI）のカスタム設定ファイル集です。

## 機能

### ステータスライン

[robbyrussell](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes#robbyrussell) テーマ風のステータスラインです。

**表示内容：** プロジェクト名、Gitブランチ（+ dirty フラグ）、モデル名、コンテキスト使用率、セッションコスト、5h / 7d クォータ（カウントダウン付）

**主な機能：**
- ワークツリー対応: `claude -w` 使用時でも元のプロジェクト名を表示
- ブランチ名省略: `worktree-*` → `wt:`, `feature/*` → `f/`, `fix/*` → `x/`
- クォータ使用量を色分け: 緑 (<50%)、黄 (50-79%)、赤 (>=80%)
- クォータデータは5分キャッシュ（失敗時は10分バックオフ）
- クロスプラットフォーム: Windows (Git Bash)、Linux、macOS で動作

### カスタムスキル

- **`/review-pr`** — PRのコードレビューを実施し、コメントとして投稿
- **`/copilot-review`** — GitHub Copilotによるレビューをリクエスト

## インストール

### 前提条件

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) がインストール済み
- `jq` — JSONプロセッサ（ステータスライン用）
- `curl` — HTTPクライアント（クォータ取得用）
- `git` — ブランチ/ワークツリー検出用

### クイックインストール

```bash
git clone https://github.com/sudolifeagain/claude-code-config.git
cd claude-code-config
bash install.sh
```

### 手動インストール

1. ステータスラインスクリプトをコピー:

```bash
cp statusline-command.sh ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
```

2. `~/.claude/settings.json` に以下を追加:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-command.sh"
  }
}
```

3. (任意) スキルのインストール:

```bash
cp -r skills/* ~/.claude/skills/
```

## アンインストール

```bash
cd claude-code-config
bash uninstall.sh
```

その後、`~/.claude/settings.json` から `"statusLine"` のエントリを削除してください。
