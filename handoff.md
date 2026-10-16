# Session Handoff
**Date**: 2026-10-16
**Branch**: feat/antigravity-parity

## What Was Done
- Audited Antigravity (2.0 App, Antigravity IDE, Antigravity CLI `agy`) customization ingestion against official docs (`agy-customizations`, `antigravity-guide`, `migrate-workflows`) and live session state.
- Fixed YAML frontmatter syntax errors (unquoted `: ` and unindented multiline quoted strings) in `creator-outreach`, `n8n-code-tool`, `using-n8n-mcp-skills`, `ai-system-build-gate`, `api-security-best-practices`, `data-privacy-compliance`, `sql-injection-testing`, and `vulnerability-scanner` (`creator-outreach` was previously dropped silently by Antigravity's parser).
- Removed `disable-model-invocation: true` from `model-serving-strategy` and `using-n8n-mcp-skills` so they match `global-instructions.md` and their own descriptions.
- Added explicit `tools:` frontmatter to `agents/adviser.md` (`Read, Grep, Glob`) and `agents/explorer.md` (`Read, Grep, Glob, Write`) so sync scripts no longer grant them `Bash` or `Edit` by default.
- Upgraded `antigravity/sync-antigravity.sh` and added `antigravity/hooks-adapter.sh` + `antigravity/sync-antigravity.test.ts` (8 bun tests passing):
  - Generates `~/.gemini/config/agents/*.md` with `enable_write_tools: true|false` and actual Antigravity tool names (`view_file`, `run_command`, `replace_file_content`, `write_to_file`).
  - Generates `~/.gemini/config/rules/*.md` converting `paths:` into `trigger: glob` + `globs:`.
  - Generates `~/.gemini/config/command-skills/<cmd>/SKILL.md` + `~/.gemini/config/skills.json` from `commands/*.md` (with `disable-model-invocation: true`) and removes the deprecated `global_workflows` symlink.
  - Generates `~/.gemini/config/hooks.json` bridging `PreToolUse` (`pre-push-public-check.sh`, `sensitive-file-guard.sh`, `package-manager-nudge.sh`, `pre-tool-git-check.sh`) and `PostToolUse` (`format-after-edit.sh`).
- Updated `CLAUDE.md`, `README.md`, `codebase-map.md`, and `ROADMAP.md` for the 3-surface Antigravity architecture (2.0 App, IDE, CLI `agy`).

## In Progress
- None

## Blockers / Open Questions
- Built-in Antigravity plugins (`science` alone adds 25 skills, `firebase` adds 10) consume a large share of the skills context budget, causing 6 global skills (`ai-system-build-gate`, `bug-report-writer`, `data-privacy-compliance`, `hf-cli`, `modern-web-guidance`, `vulnerability-scanner`) to be budget-excluded until unused built-in plugins are disabled in the Antigravity Plugins UI.

## Next Steps
1. Restart Antigravity (App / IDE / CLI) so the newly generated `agents/`, `rules/`, `command-skills/` (`skills.json`), `hooks.json`, and fixed `creator-outreach` skill load into the session.
2. Disable unused built-in plugins (e.g. `science`) in Antigravity's Plugins page (`customization://science`) to reclaim the skills context budget.
3. Run `./opencode/sync-opencode.sh` if not yet run outside the sandbox so OpenCode picks up the tightened `adviser` and `explorer` permissions.

## Files to Review First
- `antigravity/sync-antigravity.sh`
- `antigravity/hooks-adapter.sh`
- `antigravity/sync-antigravity.test.ts`
- `CLAUDE.md`
- `README.md`
