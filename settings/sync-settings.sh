#!/usr/bin/env bash
# Single edit point for Claude Code settings.
#
#   push (default)  settings/claude-settings.json  ->  ~/.claude/settings.json
#   pull            ~/.claude/settings.json        ->  settings/claude-settings.json
#   diff            show drift between the two
#
# claude-settings.json is GITIGNORED on purpose: it carries a live context7 API
# key, a GitLab deploy token, an internal hostname and machine-specific paths.
# This repo is public. Only this script is tracked.
#
# Use `pull` after changing anything through /config, /model, /permissions or
# /plugin — Claude Code writes those straight to the live file, and the repo
# copy goes stale otherwise.

set -euo pipefail

REPO_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/claude-settings.json"
LIVE_FILE="$HOME/.claude/settings.json"
mode="${1:-push}"

backup() {
  [ -f "$1" ] || return 0
  cp "$1" "$1.bak-sync-$(date +%Y%m%d-%H%M%S)"
}

validate() {
  jq -e . "$1" >/dev/null 2>&1 || {
    echo "ERROR: $1 is not valid JSON — refusing to sync." >&2
    exit 1
  }
}

case "$mode" in
  push)
    [ -f "$REPO_FILE" ] || { echo "ERROR: $REPO_FILE missing. Run '$0 pull' first." >&2; exit 1; }
    validate "$REPO_FILE"
    backup "$LIVE_FILE"
    cp "$REPO_FILE" "$LIVE_FILE"
    chmod 600 "$LIVE_FILE"
    echo "pushed -> ~/.claude/settings.json"
    echo "restart Claude Code for hook, plugin and permission changes to apply."
    ;;
  pull)
    validate "$LIVE_FILE"
    backup "$REPO_FILE"
    cp "$LIVE_FILE" "$REPO_FILE"
    chmod 600 "$REPO_FILE"
    echo "pulled -> settings/claude-settings.json"
    ;;
  diff)
    if diff <(jq -S . "$REPO_FILE") <(jq -S . "$LIVE_FILE"); then
      echo "in sync"
    else
      echo "--- drift above: left=repo, right=live ---"
    fi
    ;;
  *)
    echo "usage: ${0##*/} [push|pull|diff]" >&2
    exit 1
    ;;
esac
