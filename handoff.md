# Session Handoff
**Date**: 2026-10-16
**Branch**: main

## What Was Done
- Design tooling from the "5 Herramientas" video (revolutia), mapped to repos: Leonxlnx/taste-skill (Taste Skill + Image to Code), vercel-labs/agent-skills `web-design-guidelines` (already in `skills/`), VoltAgent/awesome-design-md, microsoft/playwright-cli.
- `skill-safety-check` on taste-skill (FLAGGED, minor: oversized and Codex-only sub-skills, `full-output-enforcement` too broad, writes `~/.taste-skill/history.json`) and awesome-design-md (plain markdown, no skill manifest, clean).
- Vendored outside every skills dir: `~/vendor-skills/taste-skill` (`f624f37`), `~/vendor-skills/awesome-design-md` (`3b60532`). Never auto-loaded.
- `global-instructions.md` "Design & Frontend" section: when to Read which file, screenshot-to-code flow, `playwright-cli` preferred over MCP for visual checks, taste-skill wins aesthetic conflicts, excluded sub-skills listed.
- `frontend-design` plugin disabled in `settings/claude-settings.json`, pushed live (in sync).
- `@playwright/cli@0.1.22` installed globally with bun (skills-less mode; `install --skills` deliberately not run).

## In Progress
- None

## Blockers / Open Questions
- Upstream `taste-skill/tests/skill_test.sh` fails 5/5 on macOS bash 3.2 (`skill.sh` uses `declare -A`). `skill.sh` is unused by the routing; not patched.
- Should accessibility (WCAG) be exempt from "taste-skill wins conflicts"? Not decided.

## Next Steps
1. Restart Claude Code: `frontend-design` disable and the new `global-instructions.md` section apply only after restart.
2. Try the routing on a real UI task; check Claude reads taste-skill only then.
3. Before any `git pull` in `~/vendor-skills/*`, run `skill-safety-check` on the diff.

## Key Context
- Tested this session: taste-skill `lint.mjs` (3 FAIL on fixture), `draw.mjs --sector restaurant`, `inspect.mjs` (headless Chrome, 1440/390 renders), `assets.mjs` (Openverse search); `playwright-cli` open/snapshot/screenshot/close on a local fixture. Node v24.14.1, Chrome at `/Applications`.
- Port 8765 is taken by another local app (stemflow); pick a free port for test servers.
- `draw.mjs` writes `~/.taste-skill/history.json` unless `TASTE_SKILL_HISTORY` is set.
- Earlier-session context still valid: never symlink agents into OpenCode/Antigravity (generate them); use `scripts/skill-trigger-eval.py` for installed-skill trigger evals; rtk hook truncates long piped output.

## Files to Review First
- `global-instructions.md` ("Design & Frontend")
- `ROADMAP.md`
- `~/vendor-skills/taste-skill/skills/taste-skill/SKILL.md`
