#!/usr/bin/env bash
# SessionStart hook — unified init:
#   1. git status + repo-missing advisory
#   2. rtk presence + version
#   3. graphify presence
#   4. caveman override → LITE (plugin defaults to full)

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

# 2. RTK
if command -v rtk >/dev/null 2>&1; then
  rtk_ver=$(rtk --version 2>/dev/null | head -1 | tr -d '\n')
  rtk_line="rtk: ${rtk_ver} (PreToolUse hook active)"
else
  rtk_line="rtk: NOT INSTALLED — run: brew install rtk && rtk init -g"
fi

# 3. graphify
if command -v graphify >/dev/null 2>&1; then
  graphify_line="graphify: installed (trigger with /graphify .)"
else
  graphify_line="graphify: NOT INSTALLED — run: pip install graphifyy && graphify install"
fi

# 4. Caveman level override (plugin hardcodes 'full' at SessionStart; override to lite)
cave_line="caveman: OVERRIDE level=LITE (user default). Drop filler and pleasantries, KEEP articles, KEEP grammar. Fragments OK only when natural. Technical terms exact. Code/commits/security: normal prose. This supersedes any 'full' level set by the caveman plugin for this session unless user explicitly runs /caveman full or /caveman ultra."

# 5. Codebase map check
if [ -f "$cwd/codebase-map.md" ]; then
  map_line="codebase-map: found at root"
else
  dir_count=$(find "$cwd" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  if [ "$dir_count" -gt 5 ]; then
    map_line="codebase-map: MISSING — run /map-codebase for context on ${dir_count} top-level dirs"
  else
    map_line="codebase-map: not needed (${dir_count} dirs)"
  fi
fi

date_str=$(date +%Y-%m-%d)

msg="[session-init] ${date_str}
${git_line}
${rtk_line}
${graphify_line}
${cave_line}
${map_line}"

jq -n --arg m "$msg" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$m}}'
