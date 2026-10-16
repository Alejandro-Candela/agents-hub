# Session Handoff
**Date**: 2026-10-16
**Branch**: main

## What Was Done
- OpenCode parity `4bc8a42`: `opencode/sync-opencode.sh` (symlinks commands, generates agents, symlinks plugins) + `opencode/plugins/pre-push-public-check.ts`. Plugin verified end-to-end in a live OpenCode session (bash tool call blocked with hook message).
- Marketing skills `e9e7fc0`: `skills/seo-content-strategy/`, `skills/reddit-growth/`, `skills/creator-outreach/` (mandatory intake).
- `skills/market-research/` + Step 2 wiring into the three marketing skills (PR #3, merge `f03f0f3`, commits `5c0a52a`, `ec697bb`).
- Trigger evals: 45/48 first pass, no false positives. Descriptions of `reddit-growth` and `creator-outreach` extended; retests pass. `market-research` 10/10.
- Hook fix `b7e750b` (`curl --max-time` instead of missing macOS `timeout`); rule "Ask, Don't Assume" `a8959c0` (`global-instructions.md:68`).
- `linkedin.md` gitignored; `ROADMAP.md` created.
- Outside repo: `~/.config/opencode/opencode.json` `ralph-loop-agent-mode` path fixed (backup `opencode.json.bak-ralphpath-*`); OpenCode stubs `tdd-vertical-slice`, `deep-module-design` deleted.
- PRs #1, #2, #3 merged to main; `feat/frontend-design-skills`, `feat/opencode-parity`, `feat/v2-1-286-harness-upgrade` deleted.

## In Progress
- None

## Blockers / Open Questions
- Leftover agent worktree `.claude/worktrees/agent-add2fe7ab63c15ffe` + branch `worktree-agent-add2fe7ab63c15ffe`; not checked (classifier gave no verdict). Remove with `git worktree remove` once confirmed clean.
- Pre-push hook cannot detect private repos (unauthenticated API 404) -> scanned as public. Fail-safe.

## Next Steps
1. Remove the agent worktree (command above) after checking it is clean
2. Pick the next item from `ROADMAP.md` "Next" (OpenCode hook parity for safety hooks first)

## Key Context
- Never symlink agents into OpenCode: Claude `tools:` string is invalid there and one bad file breaks the whole config. Re-run `./opencode/sync-opencode.sh` after agent/command changes.
- skill-creator `run_eval.py` is useless for already-installed skills (always 0%). Working method: `claude -p --output-format stream-json --verbose`, detect `tool_use` name `Skill` with `input.skill`. Scripts were in scratchpad (not kept).
- Claude Code's skill listing truncated a description at `#`; avoid `#` in descriptions.
- Short answerable questions undertrigger skills; an explicit "Also use when ..." clause fixed each miss.
- rtk PreToolUse hook truncates long piped output and rewrites `git`/`grep`; write output to a file first. Subagents in worktrees needed `/usr/bin/git`.
- OpenCode state: `opencode debug config`, `opencode debug skill`.

## Files to Review First
- `ROADMAP.md`
- `opencode/sync-opencode.sh`
- `opencode/plugins/pre-push-public-check.ts`
- `hooks/pre-push-public-check.sh`
- `skills/market-research/SKILL.md`
- `skills/seo-content-strategy/SKILL.md`, `skills/reddit-growth/SKILL.md`, `skills/creator-outreach/SKILL.md`
- `global-instructions.md:67-68`
