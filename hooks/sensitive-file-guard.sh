#!/usr/bin/env bash
# PreToolUse hook (Write|Edit) — deny writes to files that look like secrets.
# Shared by Claude Code (settings PreToolUse) and OpenCode
# (opencode/plugins/sensitive-file-guard.ts), so the pattern lives here only.

set -euo pipefail

f=$(jq -r '.tool_input.file_path // .tool_input.filePath // ""')

if echo "$f" | grep -qiE '(\.env|\.env\.|credentials|secret|key\.(json|yaml|yml|pem|p12))'; then
  jq -n --arg f "$f" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:("BLOCKED: Attempting to write to a sensitive file (" + $f + "). Review carefully before proceeding.")}}'
else
  echo '{}'
fi
