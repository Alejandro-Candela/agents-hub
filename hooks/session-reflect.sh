#!/usr/bin/env bash
# SessionEnd hook — prompts for self-improvement of CLAUDE.md files.

set -euo pipefail

msg="[session-reflect] Session ending. Did you learn any new project-specific conventions, discover an outdated CLAUDE.md rule, or encounter model-specific workarounds that should be updated? If so, propose an update to the local CLAUDE.md or global instructions."

jq -n --arg m "$msg" '{hookSpecificOutput:{hookEventName:"SessionEnd",additionalContext:$m}}'
