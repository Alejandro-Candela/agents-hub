# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Harness configuration, not application code. One source of truth (`global-instructions.md`, `agents/`, `commands/`, `hooks/`, `skills/`) fanned out via symlinks into three incompatible agentic-coding harnesses: Claude Code, Antigravity, and OpenCode. There is nothing to build or deploy — the "product" is the symlink graph plus the JSON/markdown it points at. See `README.md` for the full symlink ritual per harness.

## Commands

No build, lint, or test framework — this is bash + JSON + markdown. The equivalent workflows:

**Validate a hook script before wiring it up:**
```bash
bash -n hooks/<script>.sh                    # syntax check
echo '{"tool_input":{...}}' | bash hooks/<script>.sh | jq .   # run it against fake harness input, verify the JSON shape
```
Always test both branches of a hook (the fires case and the silent-pass case) before pushing it live — see "Hook output schema" below for why this matters.

**Edit live Claude Code settings** (hooks wiring, permissions, model, plugins):
```bash
./settings/sync-settings.sh          # push settings/claude-settings.json -> ~/.claude/settings.json
./settings/sync-settings.sh pull     # capture changes made via /config, /model, /permissions, /plugin back into the repo
./settings/sync-settings.sh diff     # show drift between repo and live file
```
`settings/claude-settings.json` is the only file you edit for Claude Code settings; it's gitignored (holds a live API key and a deploy token) and is never symlinked, because Claude Code rewrites `settings.json` in place and that would clobber a symlink. Run `pull` after any `/config`/`/model`/`/permissions`/`/plugin` change or the next `push` silently reverts it. Restart Claude Code after a push — hook, plugin, and permission changes don't apply mid-session.

**Verify the symlink graph landed:**
```bash
ls -la ~/.claude/CLAUDE.md ~/.claude/agents ~/.claude/commands ~/.claude/hooks ~/.claude/skills
```

## Architecture

**Master brain:** `global-instructions.md` is symlinked to `~/.claude/CLAUDE.md`, `~/.gemini/GEMINI.md`, and `~/.gemini/antigravity/instructions.md`, and is the sole entry in OpenCode's `opencode.json` → `instructions` array. One edit, three harnesses pick it up on their next session (Claude Code needs `/clear`/`/compact`/restart — editing it mid-session does not invalidate the prompt cache but also does not apply).

**The three harnesses are not symmetric — don't assume a slash command exists everywhere:**
- Claude Code gets everything: `agents/`, `commands/`, `hooks/`, `skills/`, plus (once created) `~/.claude/rules/` for a second, `paths:`-scoped instructions file.
- Antigravity gets `commands/` (via `~/.gemini/config/global_workflows`) and `skills/`, but has no `agents/` symlink — the adviser/explorer subagents are unreachable there.
- OpenCode only has 5 commands hand-ported into `~/.config/opencode/commands/` (`grill-me`, `ralph-loop`, `ralph-loop-afk`, `tdd-vertical-slice`, `deep-module-design`) and no `skills/` symlink at all. Most of `commands/` referenced in `global-instructions.md` (`/scout`, `/primer`, `/handoff`, `/prep`, `/map-codebase`, `/smart-compact`) don't exist there.

**`hooks/peon-ping/` is not this repo's content.** `peon.sh` and most of that subdirectory are symlinks into a Homebrew-installed package (`/opt/homebrew/opt/peon-ping/libexec/`). Never edit those files — `brew upgrade peon-ping` overwrites them. Only the wiring (which events call it, with what matcher) lives in `settings/claude-settings.json`.

**Model aliases only, never a version string.** `settings/claude-settings.json`'s top-level `"model"` and any agent/skill frontmatter `model:` field use family aliases (`opus`, `sonnet`, `haiku`, `fable`) — never a dated snapshot like `claude-opus-5-5`. Aliases roll forward automatically when Anthropic ships the next model; snapshots go stale silently and this has broken things twice already. Also never set `ANTHROPIC_MODEL`/`ANTHROPIC_DEFAULT_*_MODEL` as shell env vars — they outrank every settings file and don't show up in `/model`, so a stale one is invisible until something breaks.

**Skills auto-invoke by default; most in this repo don't.** A `SKILL.md` with `disable-model-invocation: true` in frontmatter can only be reached via its explicit `/name` command — currently true for the majority of `skills/`. Check a skill's frontmatter before assuming the model will pick it up on its own.

**Hook output schema is strict and event-specific — this has broken twice already:**
- The legacy `{"decision":"allow"|"block"}` shape is deprecated. Use `{}` (or omit output) to allow, and `{"hookSpecificOutput":{"hookEventName":"<Event>","permissionDecision":"deny","permissionDecisionReason":"..."}}` to deny.
- `hookSpecificOutput.hookEventName` must exactly match the event that actually fired (e.g. a hook wired to `PostToolUseFailure` must emit `"PostToolUseFailure"`, not `"PostToolUse"`) — copy-pasting a hook between events without updating this field fails validation.
- `SessionEnd` cannot emit `hookSpecificOutput.additionalContext` at all — the conversation is already closed, there's no live turn to feed context into. Use the top-level `systemMessage` field instead, which prints to the terminal for the human to read.
- Test every hook against real fake input (see Commands above) before trusting it; a broken hook fails silently until something exercises the exact code path that emits bad JSON.

**`.gitignore` excludes two categories on purpose:** live secrets/machine-specific config (`mcp/mcp_config.json`, `settings/claude-settings.json*`) synced by hand via their own scripts, and appliedAI-branded/proprietary material (`*applied*`, `skills/knowledge-base`) whose actual content lives outside this repo and is symlinked in separately — this repo itself is public.
