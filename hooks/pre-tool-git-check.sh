#!/usr/bin/env bash
# PreToolUse hook — scans for secrets before git operations

set -euo pipefail

cwd="${CLAUDE_PROJECT_DIR:-$PWD}"
msg=""

# Only check if inside a git repo
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  staged_files=$(git -C "$cwd" diff --cached --name-only 2>/dev/null || true)
  if echo "$staged_files" | grep -iqE '\.env|secret|credential|password|key'; then
    msg="⚠️ WARNING [pre-tool-git-check]: You have files staged that look like secrets (.env, credentials, keys). STOP and review the staging area before running 'git commit' or 'git push'."
  fi
fi

if [ -n "$msg" ]; then
  jq -n --arg m "$msg" '{hookSpecificOutput:{hookEventName:"PreToolUse",additionalContext:$m}}'
else
  jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse"}}'
fi
