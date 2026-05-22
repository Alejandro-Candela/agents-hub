#!/usr/bin/env bash
# PostToolUse hook — trims pytest/jest/vitest/bun-test output.
# Reads Claude hook JSON on stdin, emits JSON on stdout.
# Only rewrites tool_response when command matches a test runner AND stdout is verbose.

set -euo pipefail

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // ""')

if ! echo "$cmd" | grep -qE '\b(pytest|jest|vitest|bun test|npm test|uv run pytest|make test)\b'; then
  echo '{}'
  exit 0
fi

stdout=$(echo "$input" | jq -r '.tool_response.stdout // .tool_response.output // ""')
stderr=$(echo "$input" | jq -r '.tool_response.stderr // ""')

# Keep lines containing signal.
pattern='FAIL|FAILED|ERROR|Error:|AssertionError|Traceback|===|short test summary|passed|failed|errors|warnings'
filtered=$(echo "$stdout" | grep -E "$pattern" || true)

# If filtered output is tiny (no failures), keep only the summary tail.
if [ -z "$filtered" ]; then
  filtered=$(echo "$stdout" | tail -n 15)
fi

# Cap filtered size.
filtered=$(echo "$filtered" | tail -n 120)

msg="[test-output-filter] kept failures + summary (dropped passing lines)"
jq -n --arg s "$filtered" --arg e "$stderr" --arg m "$msg" \
  '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:($m+"\n---STDOUT---\n"+$s+(if $e=="" then "" else "\n---STDERR---\n"+$e end))}}'
