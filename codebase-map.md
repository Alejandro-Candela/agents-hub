# Codebase Map

| Folder | What lives there |
|---|---|
| `agents/` | Subagent definitions (Claude Code format); source for generated OpenCode and Antigravity agents |
| `antigravity/` | `sync-antigravity.sh` and `hooks-adapter.sh`: generates Antigravity agents, rules, command-skills, and `hooks.json` |
| `commands/` | Slash commands; symlinked into Claude Code and OpenCode, generated as command-skills for Antigravity |
| `hooks/` | Claude Code hook scripts, shared with OpenCode plugins and Antigravity's `hooks-adapter.sh`; `peon-ping/` is a Homebrew symlink, not repo content |
| `mcp/` | Canonical MCP server list (`mcp_config.json`, gitignored: holds secrets) |
| `opencode/` | `sync-opencode.sh` and `plugins/*.ts` that bridge hooks into OpenCode |
| `rules/` | Path-scoped instruction files (Python, TypeScript); symlinked into Claude Code, generated for Antigravity |
| `scripts/` | Repo tooling, e.g. `skill-trigger-eval.py` |
| `settings/` | `sync-settings.sh` for `~/.claude/settings.json` (repo copy gitignored) |
| `skills/` | All skills, one folder each (86 sub-folders): run `/map-codebase skills` for next level |
| `.github/` | CI workflows |

Root files: `global-instructions.md` (master instructions, symlinked into all harnesses), `CLAUDE.md`, `README.md`, `ROADMAP.md`, `handoff.md`.
