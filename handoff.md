# Session Handoff
**Date**: 2026-10-16
**Branch**: main

## What Was Done
- OpenCode parity: agents/commands via `opencode/sync-opencode.sh` (`4bc8a42`); hooks via `opencode/plugins/`: `pre-push-public-check.ts`, `sensitive-file-guard.ts` (block), `claude-hooks-bridge.ts` (format-after-edit, package-manager-nudge, pre-tool-git-check appended to tool output; precompact-state into compaction). 12 bun tests; guard, nudge and pre-push verified in live OpenCode sessions.
- Antigravity subagents: `antigravity/sync-antigravity.sh` generates `~/.gemini/config/agents/*.md` (9 agents, tool names mapped to Antigravity's documented names).
- Hooks: `hooks/sensitive-file-guard.sh`, `hooks/package-manager-nudge.sh` extracted from inline settings; `settings/claude-settings.json` rewired and pushed live (in sync). Pre-push: macOS `timeout` fix (`b7e750b`) and private-repo detection via `gh api`.
- Skills: `seo-content-strategy`, `reddit-growth`, `creator-outreach` (`e9e7fc0`), `market-research` (PR #3, `f03f0f3`); trigger evals 45/48 then description fixes; `market-research` 10/10. Tool: `scripts/skill-trigger-eval.py`.
- `global-instructions.md:68` "Ask, Don't Assume" (`a8959c0`); `codebase-map.md`; `ROADMAP.md`; `linkedin.md` gitignored.
- Outside repo: `opencode.json` `ralph-loop-agent-mode` path fixed; OpenCode stubs deleted; merged branches and agent worktree removed.

## In Progress
- None

## Blockers / Open Questions
- None. Accepted limits: Antigravity agents not load-tested (no Antigravity CLI on this machine); pre-push treats a repo as public when `gh` is not authenticated.

## Next Steps
1. Restart Claude Code so the rewired PreToolUse hooks (`sensitive-file-guard.sh`, `package-manager-nudge.sh`) load.
2. Nothing else queued; `ROADMAP.md` has only the recurring maintenance review.

## Key Context
- Never symlink agents into OpenCode or Antigravity: both need generated files (OpenCode rejects Claude's `tools:` string and then the whole config; Antigravity can hang on unknown tool names). Re-run both sync scripts after editing `agents/`.
- OpenCode loads every `.ts` in `plugins/`, so shared helpers can't live there; each plugin is self-contained and shells out to `~/.claude/hooks/*.sh`.
- Claude advisory hooks (`additionalContext`) have no OpenCode equivalent; the bridge appends them to `output.output` in `tool.execute.after`.
- skill-creator `run_eval.py` reports 0% for installed skills; use `scripts/skill-trigger-eval.py`.
- Claude Code's skill listing cut a description at `#`; avoid `#` in descriptions.
- rtk PreToolUse hook truncates long piped output and rewrites `git`/`grep`; write output to a file first.

## Files to Review First
- `ROADMAP.md`
- `codebase-map.md`
- `opencode/plugins/claude-hooks-bridge.ts`
- `opencode/sync-opencode.sh`, `antigravity/sync-antigravity.sh`
- `hooks/pre-push-public-check.sh`, `hooks/sensitive-file-guard.sh`
- `skills/market-research/SKILL.md`
- `CLAUDE.md` (Architecture: harness bullets)
