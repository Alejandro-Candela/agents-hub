#!/usr/bin/env bash
# PostToolUseFailure hook — reminds agent to invoke Adviser if stuck

set -euo pipefail

msg="[post-error-adviser] Reminder: If you are stuck debugging the same issue multiple times, or going in circles, STOP executing tools and invoke the adviser subagent (Agent tool, subagent_type: adviser) for strategic guidance."

jq -n --arg m "$msg" '{hookSpecificOutput:{hookEventName:"PostToolUseFailure",additionalContext:$m}}'
