#!/usr/bin/env bash
# PreCompact hook — auto-compaction is the case that loses state without warning.
# Leaves a recoverable breadcrumb and tells Claude what must survive the summary.

set -uo pipefail

input=$(cat)
trigger=$(echo "$input" | jq -r '.trigger // "unknown"')
transcript=$(echo "$input" | jq -r '.transcript_path // ""')
cwd=$(echo "$input" | jq -r '.cwd // ""')

branch=""
[ -n "$cwd" ] && branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || true)

printf '%s\t%s\t%s\t%s\t%s\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$trigger" "${cwd:-?}" "${branch:-no-git}" "${transcript:-?}" \
  >> "$HOME/.claude/precompact.log"

jq -n '{hookSpecificOutput:{hookEventName:"PreCompact",additionalContext:"[precompact-state] Compaction is running. Carry these into the summary or they are lost: (1) the task in progress and its stated success criteria, (2) files edited but not yet verified, (3) any test currently failing or never run, (4) decisions the user already made — do not re-litigate them after compacting. Breadcrumb appended to ~/.claude/precompact.log."}}'
