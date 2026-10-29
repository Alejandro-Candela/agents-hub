#!/usr/bin/env bash
# PostToolUseFailure hook — reminds agent to invoke Adviser if stuck.
# Ignores benign non-zero lookup exits (grep, rg, diff, test, which).

set -euo pipefail

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // ""')

if echo "$cmd" | grep -qE '^[[:space:]]*(grep|rg|find|diff|git[[:space:]]+diff|ls|which|command[[:space:]]+-v|test|\[)\b'; then
  echo '{}'
  exit 0
fi

msg="[post-error-adviser] If stuck after 2+ failed attempts on the same issue, stop and invoke the adviser subagent."

jq -n --arg m "$msg" '{hookSpecificOutput:{hookEventName:"PostToolUseFailure",additionalContext:$m}}'
