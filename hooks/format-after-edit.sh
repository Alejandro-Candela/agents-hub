#!/usr/bin/env bash
# PostToolUse hook (Write|Edit) — formats the edited file with the project's own
# tooling and feeds back only what the formatter could NOT fix.
#
# Rules:
#   - never installs anything: uvx/bunx run only when the project already has
#     the matching config, so nothing is downloaded behind the user's back
#   - never fails the tool call: always exits 0 with valid JSON
#   - silent on success; unfixable findings go back to Claude as context

set -uo pipefail

input=$(cat)
file=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.filePath // ""')

[ -n "$file" ] && [ -f "$file" ] || { echo '{}'; exit 0; }

# Nearest project root, max 6 hops up.
root=$(dirname "$file")
for _ in 1 2 3 4 5 6; do
  [ -f "$root/pyproject.toml" ] || [ -f "$root/package.json" ] && break
  parent=$(dirname "$root")
  [ "$parent" = "$root" ] && break
  root="$parent"
done

py_fmt() {
  local ruff=""
  if command -v ruff >/dev/null 2>&1; then
    ruff="ruff"
  elif [ -x "$root/.venv/bin/ruff" ]; then
    ruff="$root/.venv/bin/ruff"
  elif [ -f "$root/pyproject.toml" ] && command -v uv >/dev/null 2>&1 \
       && (cd "$root" && uv run --quiet ruff --version >/dev/null 2>&1); then
    cd "$root" || return 0
    uv run --quiet ruff format "$1" >/dev/null 2>&1
    uv run --quiet ruff check --fix "$1" 2>&1
    return $?
  else
    return 0   # project has no ruff — stay silent
  fi
  "$ruff" format "$1" >/dev/null 2>&1
  "$ruff" check --fix "$1" 2>&1
}

ts_fmt() {
  # Only the project's own installed binaries. Never bunx/npx: that downloads.
  if [ -x "$root/node_modules/.bin/biome" ]; then
    cd "$root" || return 0
    "$root/node_modules/.bin/biome" check --write "$1" 2>&1
  elif [ -x "$root/node_modules/.bin/prettier" ]; then
    cd "$root" || return 0
    "$root/node_modules/.bin/prettier" --write "$1" 2>&1
  else
    return 0
  fi
}

case "$file" in
  *.py)                    out=$(py_fmt "$file"); status=$? ;;
  *.ts|*.tsx|*.js|*.jsx)   out=$(ts_fmt "$file"); status=$? ;;
  *)                       echo '{}'; exit 0 ;;
esac

# status 0 means formatted clean, or no tooling present. Nothing to report.
if [ "$status" -eq 0 ] || [ -z "$out" ]; then
  echo '{}'
  exit 0
fi

out=$(echo "$out" | head -c 4000)
jq -n --arg f "$file" --arg o "$out" \
  '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:("[format-after-edit] auto-fix left unresolved issues in "+$f+" — fix them now, before moving on:\n"+$o)}}'
