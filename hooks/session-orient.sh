#!/usr/bin/env bash
# SessionStart hook — unified init:
#   1. git status + repo-missing advisory
#   2. rtk presence + version
#   3. graphify presence
#
# Caveman default mode is set via ~/.config/caveman/config.json (defaultMode: "lite"),
# the plugin's own supported mechanism — not overridden here. A prior version of this
# hook tried to override the level via injected advisory text, but the plugin's
# SessionStart/UserPromptSubmit hooks re-assert their config-resolved mode every turn,
# so the advisory text was silently losing that race.

set -euo pipefail

cwd="${CLAUDE_PROJECT_DIR:-$PWD}"

# 1. Git — read-only report. Never auto-init.
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
  dirty=$(git -C "$cwd" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  ahead_behind=$(git -C "$cwd" rev-list --left-right --count "@{u}...HEAD" 2>/dev/null \
    | awk '{printf "behind:%s ahead:%s", $1, $2}' || echo "no-upstream")
  git_line="git: ${branch} | dirty:${dirty} | ${ahead_behind}"
else
  git_line="git: NO REPO — run \`git init\` manually if this is a project directory"
fi

# 2. Missing tool warnings only (silent when installed)
warnings=""
if ! command -v rtk >/dev/null 2>&1; then
  warnings="${warnings}"$'\n'"rtk: NOT INSTALLED — run: brew install rtk && rtk init -g"
fi
if ! command -v graphify >/dev/null 2>&1; then
  warnings="${warnings}"$'\n'"graphify: NOT INSTALLED — run: uv tool install graphifyy && graphify install"
fi

# 3. Codebase map & handoff check
if [ -f "$cwd/codebase-map.md" ]; then
  map_line="codebase-map: found"
else
  dir_count=$(find "$cwd" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  if [ "$dir_count" -gt 5 ]; then
    map_line="codebase-map: MISSING — run /map-codebase (${dir_count} top-level dirs)"
  else
    map_line="codebase-map: not needed (${dir_count} dirs)"
  fi
fi

if [ -f "$cwd/handoff.md" ]; then
  handoff_date=$(grep -m1 '^\*\*Date\*\*:' "$cwd/handoff.md" 2>/dev/null | sed 's/\*\*Date\*\*:[[:space:]]*//' || echo "found")
  handoff_line="handoff: handoff.md (${handoff_date}) — read or run /primer"
else
  handoff_line="handoff: none"
fi

date_str=$(date +%Y-%m-%d)

msg="[session-init] ${date_str} | ${git_line} | ${map_line} | ${handoff_line}${warnings}"

jq -n --arg m "$msg" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$m}}'
