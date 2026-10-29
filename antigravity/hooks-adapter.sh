#!/usr/bin/env bash
# Bridge Antigravity lifecycle hooks (hooks.json) to the shared Claude Code
# scripts in hooks/*.sh.
#
# Antigravity passes camelCase JSON on stdin:
#   PreToolUse:  {"toolCall":{"name":"...","args":{...}},"workspacePaths":[...]}
#                -> expects {"decision":"allow"|"deny","reason":"..."}
#   PostToolUse: {"stepIdx":...,"workspacePaths":[...]}
#                -> expects {}

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS="$REPO/hooks"
EVENT="${1:-PreToolUse}"
INPUT="$(cat)"

tool="$(echo "$INPUT" | jq -r '.toolCall.name // ""')"
cwd="$(echo "$INPUT" | jq -r '.toolCall.args.Cwd // .workspacePaths[0] // ""')"
[ -z "$cwd" ] && cwd="$PWD"

if [ "$EVENT" = "PreToolUse" ]; then
  case "$tool" in
    run_command)
      cmd="$(echo "$INPUT" | jq -r '.toolCall.args.CommandLine // ""')"
      cmd_payload="$(jq -n --arg c "$cmd" '{tool_input:{command:$c}}')"

      res="$(echo "$cmd_payload" | CLAUDE_PROJECT_DIR="$cwd" bash "$HOOKS/pre-push-public-check.sh" 2>/dev/null || echo '{}')"
      decision="$(echo "$res" | jq -r '.hookSpecificOutput.permissionDecision // ""')"
      if [ "$decision" = "deny" ]; then
        reason="$(echo "$res" | jq -r '.hookSpecificOutput.permissionDecisionReason // "Blocked by pre-push-public-check"')"
        jq -n --arg r "$reason" '{decision:"deny",reason:$r}'
        exit 0
      fi

      nudge="$(echo "$cmd_payload" | CLAUDE_PROJECT_DIR="$cwd" bash "$HOOKS/package-manager-nudge.sh" 2>/dev/null || echo '{}')"
      nudge_ctx="$(echo "$nudge" | jq -r '.hookSpecificOutput.additionalContext // ""')"
      if [ -n "$nudge_ctx" ]; then
        jq -n --arg r "$nudge_ctx" '{decision:"ask",reason:$r}'
        exit 0
      fi

      if echo "$cmd" | grep -qE '(^|[;&|[:space:]])git[[:space:]]+(add|commit)([[:space:]]|$)'; then
        git_chk="$(echo "$cmd_payload" | CLAUDE_PROJECT_DIR="$cwd" bash "$HOOKS/pre-tool-git-check.sh" 2>/dev/null || echo '{}')"
        git_ctx="$(echo "$git_chk" | jq -r '.hookSpecificOutput.additionalContext // ""')"
        if [ -n "$git_ctx" ]; then
          jq -n --arg r "$git_ctx" '{decision:"ask",reason:$r}'
          exit 0
        fi
      fi
      ;;
    write_to_file|replace_file_content|multi_replace_file_content|write_file|edit_file)
      file="$(echo "$INPUT" | jq -r '.toolCall.args.TargetFile // .toolCall.args.Path // ""')"
      res="$(jq -n --arg f "$file" '{tool_input:{file_path:$f}}' | CLAUDE_PROJECT_DIR="$cwd" bash "$HOOKS/sensitive-file-guard.sh" 2>/dev/null || echo '{}')"
      decision="$(echo "$res" | jq -r '.hookSpecificOutput.permissionDecision // ""')"
      if [ "$decision" = "deny" ]; then
        reason="$(echo "$res" | jq -r '.hookSpecificOutput.permissionDecisionReason // "Blocked by sensitive-file-guard"')"
        jq -n --arg r "$reason" '{decision:"deny",reason:$r}'
        exit 0
      fi
      ;;
  esac
  echo '{"decision":"allow"}'
  exit 0
fi

if [ "$EVENT" = "PostToolUse" ]; then
  file="$(echo "$INPUT" | jq -r '.toolCall.args.TargetFile // .toolCall.args.Path // ""')"
  if [ -n "$file" ]; then
    jq -n --arg f "$file" '{tool_input:{file_path:$f}}' | CLAUDE_PROJECT_DIR="$cwd" bash "$HOOKS/format-after-edit.sh" >/dev/null 2>&1 || true
  fi
  echo '{}'
  exit 0
fi

echo '{}'
