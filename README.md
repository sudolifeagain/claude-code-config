# Claude Code Config

Custom configuration for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — Anthropic's official CLI for Claude.

## Features

### Responsive Status Line

A [robbyrussell](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes#robbyrussell)-inspired status line that adapts to your terminal width.

**Displayed information:**

| Element | Wide (>=130) | Medium (>=100) | Narrow (>=70) | Tiny (<70) |
|---|:---:|:---:|:---:|:---:|
| Project directory | Yes | Yes | Yes | Yes |
| Git branch + dirty flag | Full | Full | Abbreviated | Abbreviated |
| Model name | Yes | Yes | - | - |
| Context window usage | `[ctx:N%]` | `ctx:N%` | - | - |
| Session cost | `$0.1234` | `$0.12` | `$0.12` | - |
| Elapsed time | Yes | - | - | - |
| 5h / 7d usage quota | With countdown | With countdown | With countdown | With countdown |

**Key features:**
- Worktree-aware: shows the original project name even when running with `claude -w`
- Smart branch abbreviation: `worktree-*` → `wt:`, `feature/*` → `f/`, `fix/*` → `x/`
- Color-coded usage quotas: green (<50%), yellow (50-79%), red (>=80%)
- Quota data cached for 5 minutes (10 min backoff on failure)

### Custom Skills

- **`/review-pr`** — Thorough code review posted as a PR comment
- **`/copilot-review`** — Request GitHub Copilot review on a PR

### Notification Hook (Windows)

Toast notification via [BurntToast](https://github.com/Windos/BurntToast) when Claude finishes a task.

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

4. (Optional) Set up notification hooks — see `settings.example.json` for platform-specific examples.

### Notification Setup by Platform

**Windows** (requires [BurntToast](https://github.com/Windos/BurntToast) PowerShell module):

```json
{
  "hooks": {
    "Notification": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "pwsh -NoProfile -Command \"Import-Module BurntToast; New-BurntToastNotification -Text 'Claude Code', 'Task complete' -Silent\""
      }]
    }]
  }
}
```

**macOS:**

```json
{
  "hooks": {
    "Notification": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "osascript -e 'display notification \"Task complete\" with title \"Claude Code\"'"
      }]
    }]
  }
}
```

**Linux** (requires `notify-send`):

```json
{
  "hooks": {
    "Notification": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "notify-send 'Claude Code' 'Task complete'"
      }]
    }]
  }
}
```

## Uninstall

```bash
cd claude-code-config
bash uninstall.sh
```

Then manually remove the `"statusLine"` and `"hooks"` entries from `~/.claude/settings.json`.

## File Structure

```
claude-code-config/
├── README.md
├── install.sh                  # Installer script
├── uninstall.sh                # Uninstaller script
├── settings.example.json       # Example settings.json
├── statusline-command.sh       # Status line script
├── skills/
│   ├── copilot-review/SKILL.md # /copilot-review skill
│   └── review-pr/SKILL.md      # /review-pr skill
└── .gitignore
```

## License

MIT

---

# Claude Code Config (日本語)

[Claude Code](https://docs.anthropic.com/en/docs/claude-code)（Anthropic公式CLI）のカスタム設定ファイル集です。

## 機能

### レスポンシブ・ステータスライン

[robbyrussell](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes#robbyrussell) テーマ風のステータスラインです。ターミナルの横幅に応じて表示内容を自動調整します。

**表示内容：**

| 項目 | Wide (>=130) | Medium (>=100) | Narrow (>=70) | Tiny (<70) |
|---|:---:|:---:|:---:|:---:|
| プロジェクト名 | 表示 | 表示 | 表示 | 表示 |
| Gitブランチ + dirty | フル | フル | 省略 | 省略 |
| モデル名 | 表示 | 表示 | - | - |
| コンテキスト使用率 | `[ctx:N%]` | `ctx:N%` | - | - |
| セッションコスト | `$0.1234` | `$0.12` | `$0.12` | - |
| 経過時間 | 表示 | - | - | - |
| 5h / 7d クォータ | カウントダウン付 | カウントダウン付 | カウントダウン付 | カウントダウン付 |

**主な機能：**
- ワークツリー対応: `claude -w` 使用時でも元のプロジェクト名を表示
- ブランチ名省略: `worktree-*` → `wt:`, `feature/*` → `f/`, `fix/*` → `x/`
- クォータ使用量を色分け: 緑 (<50%)、黄 (50-79%)、赤 (>=80%)
- クォータデータは5分キャッシュ（失敗時は10分バックオフ）

### カスタムスキル

- **`/review-pr`** — PRのコードレビューを実施し、コメントとして投稿
- **`/copilot-review`** — GitHub Copilotによるレビューをリクエスト

### 通知フック (Windows)

[BurntToast](https://github.com/Windos/BurntToast) によるトースト通知で、Claudeがタスクを完了したことをお知らせします。

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

4. (任意) 通知フックの設定 — プラットフォーム別の例は `settings.example.json` を参照してください。各プラットフォームの設定は英語版セクションの「Notification Setup by Platform」を参照してください。

## アンインストール

```bash
cd claude-code-config
bash uninstall.sh
```

その後、`~/.claude/settings.json` から `"statusLine"` と `"hooks"` のエントリを手動で削除してください。
