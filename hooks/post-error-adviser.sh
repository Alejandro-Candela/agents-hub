#!/usr/bin/env bash
# PostToolUse hook — reminds agent to invoke Adviser if stuck

set -euo pipefail

msg="[post-error-adviser] Reminder: If you are stuck debugging the same issue multiple times, or going in circles, STOP executing tools and invoke the Opus Adviser Strategy (/agents adviser) for strategic guidance."

jq -n --arg m "$msg" '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:$m}}'
