#!/usr/bin/env bash
# SessionEnd hook — targeted self-improvement reflection.

set -euo pipefail

msg="[session-reflect] Session ending. Before closing, scan this session for:

1. NEW CONVENTIONS — Did you discover a pattern, constraint, or project-specific rule not in CLAUDE.md?
   → Propose a specific addition to the local CLAUDE.md or global-instructions.md.

2. OUTDATED RULES — Did any instruction feel unnecessary, redundant, or wrong for the current model?
   → Propose a removal or update. Models evolve — instructions for old limitations slow you down.

3. MISSING TOOLS — Was a hook, skill, or command missing that would have automated a repeated action?
   → Name it. Add a stub or note in the relevant directory.

4. MODEL-SPECIFIC WORKAROUNDS — Did any code or instruction exist only to work around a former model weakness?
   → Flag it. These become dead weight after model updates.

Files to update: local CLAUDE.md, ~/agents-hub/global-instructions.md, ~/.claude/context/anti-patterns.md
Do NOT create new files for this — edit existing ones surgically."

jq -n --arg m "$msg" '{hookSpecificOutput:{hookEventName:"SessionEnd",additionalContext:$m}}'
