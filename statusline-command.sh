#!/usr/bin/env bash
# Claude Code status line - robbyrussell theme inspired
# with 5-hour / weekly usage quota display

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# Git branch, dirty status, and project directory (single pass)
branch=""
dirty=""
dir_name="?"
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ] && git -C "$cwd" status --porcelain 2>/dev/null | grep -q .; then
    dirty="✗"
  fi
  # Use main worktree path as project name (resolves worktree → original repo)
  main_wt=$(git -C "$cwd" worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //')
  if [ -n "$main_wt" ]; then
    dir_name=$(echo "$main_wt" | sed 's|\\|/|g' | sed 's|/$||' | awk -F/ '{print $NF}')
  fi
fi

# Fallback if not a git repo or detection failed
if [ "$dir_name" = "?" ] && [ -n "$cwd" ]; then
  dir_name=$(echo "$cwd" | sed 's|\\|/|g' | sed 's|/$||' | awk -F/ '{print $NF}')
  [ -z "$dir_name" ] && dir_name="?"
fi

# Abbreviate long branch names (especially for worktree)
abbreviate_branch() {
  local b="$1"
  local max_len=25

  # Strip common worktree/feature prefixes for display
  local display="$b"
  display="${display#worktree-}"
  display="${display#feature/}"
  display="${display#feat/}"
  display="${display#fix/}"
  display="${display#bugfix/}"
  display="${display#hotfix/}"

  # If it had a prefix, show a short indicator
  local prefix_indicator=""
  if [ "$display" != "$b" ]; then
    case "$b" in
      worktree-*) prefix_indicator="wt:" ;;
      feature/*|feat/*) prefix_indicator="f/" ;;
      fix/*|bugfix/*) prefix_indicator="x/" ;;
      hotfix/*) prefix_indicator="h/" ;;
    esac
  fi

  local full="${prefix_indicator}${display}"
  if [ ${#full} -gt "$max_len" ]; then
    echo "${full:0:$(( max_len - 1 ))}…"
  else
    echo "$full"
  fi
}

# Context usage
ctx_pct=""
if [ -n "$used_pct" ]; then
  ctx_pct=${used_pct%.*}
fi

# --- Fetch 5-hour / weekly usage quota ---
CACHE_DIR="${TMPDIR:-/tmp}"
CACHE_FILE="${CACHE_DIR}/.claude-usage-cache-$(id -u 2>/dev/null || echo 0)"
CACHE_TTL=300
CACHE_TTL_FAIL=600
FAIL_MARKER="${CACHE_FILE}.fail"
five_hour=""
seven_day=""

fetch_usage() {
  CRED_FILE="$HOME/.claude/.credentials.json"
  if [ ! -f "$CRED_FILE" ]; then
    touch "$FAIL_MARKER" "$CACHE_FILE" 2>/dev/null
    return 1
  fi

  token=$(jq -r '.claudeAiOauth.accessToken // empty' "$CRED_FILE" 2>/dev/null)
  if [ -z "$token" ]; then
    touch "$FAIL_MARKER" "$CACHE_FILE" 2>/dev/null
    return 1
  fi

  response=$(curl -s --max-time 3 \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "User-Agent: claude-code-statusline/1.0" \
    "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)

  if echo "$response" | jq -e '.five_hour' > /dev/null 2>&1; then
    echo "$response" > "$CACHE_FILE"
    rm -f "$FAIL_MARKER" 2>/dev/null
    return 0
  fi
  touch "$FAIL_MARKER" 2>/dev/null
  if [ -f "$CACHE_FILE" ] && [ -s "$CACHE_FILE" ]; then
    local tmp="${CACHE_FILE}.tmp"
    cp "$CACHE_FILE" "$tmp" 2>/dev/null && mv "$tmp" "$CACHE_FILE" 2>/dev/null
  else
    touch "$CACHE_FILE" 2>/dev/null
  fi
  return 1
}

active_ttl="$CACHE_TTL"
[ -f "$FAIL_MARKER" ] && active_ttl="$CACHE_TTL_FAIL"

_file_mtime() {
  stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0
}

if [ -f "$CACHE_FILE" ]; then
  cache_age=$(( $(date +%s) - $(_file_mtime "$CACHE_FILE") ))
  [ "$cache_age" -gt "$active_ttl" ] && fetch_usage
else
  fetch_usage
fi

five_hour_reset=""
seven_day_reset=""

if [ -f "$CACHE_FILE" ]; then
  five_hour=$(jq -r '.five_hour.utilization // empty' "$CACHE_FILE" 2>/dev/null)
  seven_day=$(jq -r '.seven_day.utilization // empty' "$CACHE_FILE" 2>/dev/null)
  five_hour_reset=$(jq -r '.five_hour.resets_at // empty' "$CACHE_FILE" 2>/dev/null)
  seven_day_reset=$(jq -r '.seven_day.resets_at // empty' "$CACHE_FILE" 2>/dev/null)
fi

remaining_time() {
  local reset_at="$1"
  if [ -z "$reset_at" ]; then return; fi
  local clean=$(echo "$reset_at" | sed 's/\.[0-9]*//' | sed 's/+00:00$/+0000/' | sed 's/Z$/+0000/')
  # GNU date (Linux/Windows Git Bash) or BSD date (macOS)
  local reset_epoch=$(date -d "$clean" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S%z" "$clean" +%s 2>/dev/null)
  if [ -z "$reset_epoch" ]; then return; fi
  local now=$(date +%s)
  local diff=$(( reset_epoch - now ))
  if [ "$diff" -le 0 ]; then echo "now"; return; fi
  local days=$(( diff / 86400 ))
  local hours=$(( (diff % 86400) / 3600 ))
  local mins=$(( (diff % 3600) / 60 ))
  if [ "$days" -gt 0 ]; then
    echo "${days}d${hours}h"
  elif [ "$hours" -gt 0 ]; then
    echo "${hours}h${mins}m"
  else
    echo "${mins}m"
  fi
}

# ANSI colors
CYAN="\033[0;36m"
BLUE="\033[1;34m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
DIM="\033[2m"
RESET="\033[0m"

usage_color() {
  local val=${1%.*}
  if [ "$val" -ge 80 ] 2>/dev/null; then
    echo -ne "${RED}"
  elif [ "$val" -ge 50 ] 2>/dev/null; then
    echo -ne "${YELLOW}"
  else
    echo -ne "${GREEN}"
  fi
}

# --- Output ---
# Format: dir git:(branch) model ctx:N% $0.12 | 5h:N%(Xh) 7d:N%(Xd)

printf "${CYAN}%s${RESET}" "$dir_name"

if [ -n "$branch" ]; then
  br_display=$(abbreviate_branch "$branch")
  if [ -n "$dirty" ]; then
    printf " ${BLUE}git:(${RED}%s${BLUE})${RESET} ${YELLOW}%s${RESET}" "$br_display" "$dirty"
  else
    printf " ${BLUE}git:(${RED}%s${BLUE})${RESET}" "$br_display"
  fi
fi

if [ -n "$model" ]; then
  printf " ${DIM}%s${RESET}" "$model"
fi

if [ -n "$ctx_pct" ]; then
  printf " $(usage_color "$ctx_pct")ctx:%s%%${RESET}" "$ctx_pct"
fi

printf " ${DIM}\$%.2f${RESET}" "$cost"

# 5-hour / weekly usage quota with reset countdown
if [ -n "$five_hour" ]; then
  five_int=${five_hour%.*}
  printf " ${DIM}|${RESET} "
  printf "$(usage_color "$five_hour")5h:${five_int}%%${RESET}"
  five_remain=$(remaining_time "$five_hour_reset")
  if [ -n "$five_remain" ]; then
    printf "${DIM}(%s)${RESET}" "$five_remain"
  fi
fi

if [ -n "$seven_day" ]; then
  seven_int=${seven_day%.*}
  printf " $(usage_color "$seven_day")7d:${seven_int}%%${RESET}"
  seven_remain=$(remaining_time "$seven_day_reset")
  if [ -n "$seven_remain" ]; then
    printf "${DIM}(%s)${RESET}" "$seven_remain"
  fi
fi
