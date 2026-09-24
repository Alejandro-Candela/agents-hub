#!/usr/bin/env bash
# PreToolUse hook — before `git push` to GitHub, scan what's about to go up
# for secrets and known-internal domains. Enforcement, not a CLAUDE.md
# request: the appliedAI brand kit and an internal MCP hostname both reached
# a public GitHub repo this way before anything caught it.
#
# Does not depend on `gh auth` — that's not reliably available (confirmed
# unauthenticated in this environment), so visibility is checked via the
# unauthenticated GitHub REST API, and secret patterns are scanned
# unconditionally regardless of whether visibility could be determined.
# Failing to determine visibility means "scan as if public", never
# "skip the scan".

set -euo pipefail

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // ""')

if ! echo "$cmd" | grep -qE '(^|[;&|[:space:]])git[[:space:]]+push([[:space:]]|$)'; then
  echo '{"decision":"allow"}'
  exit 0
fi

cwd="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$cwd" 2>/dev/null || { echo '{"decision":"allow"}'; exit 0; }

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo '{"decision":"allow"}'
  exit 0
fi

remote_name=$(echo "$cmd" | grep -oE 'push[[:space:]]+--force[[:space:]]+[a-zA-Z0-9_.-]+|push[[:space:]]+[a-zA-Z0-9_.-]+' | awk '{print $NF}')
remote_name="${remote_name:-origin}"
remote_url=$(git remote get-url "$remote_name" 2>/dev/null || echo "")

[ -z "$remote_url" ] && { echo '{"decision":"allow"}'; exit 0; }

if ! echo "$remote_url" | grep -qE 'github\.com'; then
  echo '{"decision":"allow"}'
  exit 0
fi

# Diff of what's actually about to be pushed: everything reachable from HEAD
# that the remote doesn't have yet. If there's genuinely nothing new (already
# up to date, or push will just fail/no-op), there's nothing to scan — allow
# immediately rather than falling back to "last commit" and flagging content
# that isn't actually part of this push.
ahead_count=$(git rev-list --count "${remote_name}/HEAD..HEAD" 2>/dev/null || git rev-list --count "@{u}..HEAD" 2>/dev/null || echo "")

if [ "$ahead_count" = "0" ]; then
  echo '{"decision":"allow"}'
  exit 0
fi

if [ -n "$ahead_count" ]; then
  diff_content=$(git diff "${remote_name}/HEAD..HEAD" 2>/dev/null || git diff "@{u}..HEAD" 2>/dev/null || true)
else
  # No upstream tracking at all (first push of a new branch) — scan the
  # commit(s) not yet on the remote's default branch, falling back to just
  # the latest commit if that range can't be determined either.
  diff_content=$(git diff "${remote_name}/HEAD..HEAD" 2>/dev/null || true)
  [ -z "$diff_content" ] && diff_content=$(git show HEAD 2>/dev/null || true)
fi

# Hard secrets — never acceptable on any remote, public or private.
# POSIX ERE + -i, not PCRE: BSD grep (stock macOS) has no -P support.
secret_pattern='BEGIN (RSA|OPENSSH|PGP) PRIVATE KEY|AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{20,}|Authorization:[[:space:]]*(Basic|Bearer)[[:space:]]+[a-zA-Z0-9._-]{15,}|X-Atlassian-Auth'
secret_hit=$(echo "$diff_content" | grep -ioE "$secret_pattern" 2>/dev/null | sort -u | head -5 || true)

if [ -n "$secret_hit" ]; then
  msg="BLOCKED: 'git push' diff contains what looks like a credential ($(echo "$secret_hit" | tr '\n' ', ')). Review before pushing. If this is a false positive, push manually outside this hook."
  jq -n --arg m "$msg" '{decision:"block",reason:$m}'
  exit 0
fi

# Company-domain leakage check — only meaningful for a genuinely public repo.
owner_repo=$(echo "$remote_url" | sed -E 's#.*github\.com[:/]##; s#\.git$##')
visibility=""
if [ -n "$owner_repo" ]; then
  api_response=$(timeout 5 curl -s "https://api.github.com/repos/${owner_repo}" 2>/dev/null || echo "")
  if echo "$api_response" | jq -e '.private == false' >/dev/null 2>&1; then
    visibility="public"
  elif echo "$api_response" | jq -e '.private == true' >/dev/null 2>&1; then
    visibility="private"
  fi
fi

# Unknown visibility (API rate-limited, offline, repo doesn't exist yet) is
# treated the same as public: scan rather than silently skip.
if [ "$visibility" != "private" ]; then
  domain_pattern='aai\.sh|appliedai'
  domain_hit=$(echo "$diff_content" | grep -ioE "$domain_pattern" 2>/dev/null | sort -u | head -5 || true)
  if [ -n "$domain_hit" ]; then
    msg="BLOCKED: pushing to $remote_url (visibility: ${visibility:-unknown, treated as public}) and the diff mentions internal-only content ($(echo "$domain_hit" | tr '\n' ', ')). Review before pushing, or push manually if this is intentional."
    jq -n --arg m "$msg" '{decision:"block",reason:$m}'
    exit 0
  fi
fi

echo '{"decision":"allow"}'
