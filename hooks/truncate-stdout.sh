#!/usr/bin/env bash
# PostToolUse hook — truncates oversized bash stdout to head+tail, logs truncation note.
# Triggers only when stdout > 20000 chars AND command is not already a test runner
# (test runner is handled by filter-test-output.sh).

set -euo pipefail

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // ""')

# Skip if test runner — filter-test-output.sh owns that case.
if echo "$cmd" | grep -qE '\b(pytest|jest|vitest|bun test|npm test|uv run pytest|make test)\b'; then
  echo '{}'
  exit 0
fi

stdout=$(echo "$input" | jq -r '.tool_response.stdout // .tool_response.output // ""')
size=${#stdout}

if [ "$size" -le 20000 ]; then
  echo '{}'
  exit 0
fi

total_lines=$(echo "$stdout" | wc -l | tr -d ' ')
head_part=$(echo "$stdout" | head -n 60)
tail_part=$(echo "$stdout" | tail -n 60)
note="[truncate-stdout] output was ${size} bytes / ${total_lines} lines — kept head 60 + tail 60"

jq -n --arg h "$head_part" --arg t "$tail_part" --arg n "$note" \
  '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:($n+"\n---HEAD---\n"+$h+"\n...[middle cut]...\n---TAIL---\n"+$t)}}'
