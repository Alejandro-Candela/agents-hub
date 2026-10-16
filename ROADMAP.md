# Roadmap

Harness-config work only. Session-level state lives in `handoff.md`; history lives in git.

## Now

- [ ] Delete merged branch `feat/v2-1-286-harness-upgrade` (local + remote). Blocked for agents by the auto-mode classifier; run by hand: `git branch -d feat/v2-1-286-harness-upgrade && git push origin --delete feat/v2-1-286-harness-upgrade`

- [ ] Remove leftover agent worktree `.claude/worktrees/agent-add2fe7ab63c15ffe` and its local branch once confirmed clean (`git worktree remove`).

## Next

- [ ] **OpenCode hook parity.** Only `pre-push-public-check` is ported (`opencode/plugins/`). Still Claude Code only: `pre-tool-git-check`, the sensitive-file write guard and pip/npm nudge (inline in `settings/claude-settings.json`), `format-after-edit`, `filter-test-output`, `truncate-stdout`, `post-error-adviser`, `session-orient`, `precompact-state`, `session-reflect`. Port the safety ones first (git check, sensitive-file guard), same pattern: plugin shells out to the existing script.
- [ ] **Antigravity agents.** No `agents/` reach at all; check whether Antigravity has a subagent format worth generating into from `opencode/sync-opencode.sh`'s approach.
- [ ] **Pre-push private-repo detection.** Unauthenticated GitHub API 404s on private repos, so they are always scanned as public. Fail-safe, but `gh api` when authenticated would make the domain check accurate.
- [ ] **`ralph-loop` source of truth.** `ralph-loop` / `ralph-loop-afk` exist only as hand-written files in `~/.config/opencode/commands/`; move them into `commands/` if they should reach Claude Code too.

## Later

- [ ] MCP config: `mcp/mcp_config.json` is translated into each harness by hand; a sync script like `settings/sync-settings.sh` would remove the drift.
- [ ] Generate `codebase-map` (`/map-codebase`); `session-orient` reports it missing on every start.
- [ ] Trigger-eval tooling: skill-creator's `run_eval.py` reports 0% for skills that are already installed (the model calls the real skill, not the temp copy). Use a plain `claude -p` + stream-json `Skill` detection instead; consider keeping that script in the repo.
- [ ] Back-pointer from vendored `skills/seo/` to `seo-content-strategy` if routing between them proves unreliable in practice.
- [ ] Maintenance cadence review of `global-instructions.md`, hooks and skills (every 3-6 months or after a major model release).

## Done

- 2026-10-15 — OpenCode parity for agents and commands via `opencode/sync-opencode.sh`; pre-push plugin verified end-to-end in a live OpenCode session (`4bc8a42`)
- 2026-10-16 — `market-research` skill (web deep research on competitors and similar products), wired into the three marketing skills as Step 2 (PR #3, `f03f0f3`); trigger test 10/10
- 2026-10-16 — Trigger evals for the marketing skills: 45/48 at first run; `reddit-growth` and `creator-outreach` descriptions extended for the misses, retests pass
- 2026-10-15 — Marketing skills with mandatory intake: `seo-content-strategy`, `reddit-growth`, `creator-outreach` (`e9e7fc0`)
- 2026-10-15 — Pre-push hook resolves repo visibility on macOS (`b7e750b`)
- 2026-10-15 — "Ask, Don't Assume" rule in `global-instructions.md` (`a8959c0`)
- 2026-10-15 — Retired OpenCode stubs `tdd-vertical-slice`, `deep-module-design` (`87bf8a7`); `ralph-loop-agent-mode` path fixed in `opencode.json`; `linkedin.md` gitignored
