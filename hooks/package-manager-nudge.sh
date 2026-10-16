#!/usr/bin/env bash
# PreToolUse hook (Bash) — nudge pip -> uv and npm -> bun. Advisory only.
# Shared by Claude Code (settings PreToolUse) and OpenCode
# (opencode/plugins/claude-hooks-bridge.ts).

set -euo pipefail

cmd=$(jq -r '.tool_input.command // ""')

if echo "$cmd" | grep -qE '\bpip install\b'; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"WARNING: Use uv instead of pip. Run: uv add <package> or uv pip install <package>"}}'
elif echo "$cmd" | grep -qE '\bnpm install\b|\bnpm i\b'; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"WARNING: Use bun instead of npm. Run: bun add <package> or bun install"}}'
else
  echo '{}'
fi
