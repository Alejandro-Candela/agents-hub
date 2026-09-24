# Agents Hub: The AI Tamer

Welcome to **Agents Hub** — the whip, the chair, and the safety net you need to stop your AI agents (Claude Code, Antigravity, OpenCode, or whatever agentic CLI you're currently abusing) from acting like confused interns on their first day and start coding like *Senior Architects who actually read the docs*.

---

## What is this, actually?

This is not a harness. **Claude Code, Antigravity, and OpenCode are the harnesses** — the runtime layer that gives a model tools and manages the context it sees. This repo is **harness configuration**: one git-tracked source of truth (global rules, subagents, slash commands, hooks, and 40+ skills) that gets symlinked into all three.

That's the part worth stealing. Most "AI config" repos target exactly one tool. This one drives three separate, mutually incompatible config schemas from a single set of files — edit `global-instructions.md` once, and Claude Code, Antigravity, and OpenCode all pick it up on their next session, with zero re-explaining your stack, your conventions, or your gotchas per tool.

Everything else here (deterministic hooks instead of advisory nagging, on-demand skills instead of a bloated always-loaded CLAUDE.md, subagents for read-only exploration before editing) is just applying what the harnesses themselves already recommend — none of it is exotic, and symlinked dotfiles are a 15-year-old pattern (see `chezmoi`, `yadm`, `GNU stow`). The fan-out across three incompatible harnesses is the actual novelty, not the mechanism.

---

## Headaches Cured (Problems Solved)

- **The Goldfish Syndrome**: Claude will no longer forget your conventions between sessions. Context loads in lean layers — root `CLAUDE.md` for the big picture, subdirectory files for local rules. Only what's relevant gets loaded. No more re-explaining your stack every morning like you're meeting it for the first time.

- **Blind Coding ("Oops, I deleted production")**: The **Subagent Split** pattern forces Claude to explore *first*, edit *second*. The `explorer` subagent maps a subsystem in read-only mode, writes a findings file, then hands off. Shooting first and asking questions later is officially over.

- **The Grep Monkey**: No more infinite `grep` searches like a monkey banging cymbals together. Claude is forced to use **LSP** (`goToDefinition`, `findReferences`, `workspaceSymbol`) as the first option. Symbol-level precision. No false matches on identically named functions in different files.

- **Session Amnesia at Shutdown**: The `session-reflect.sh` hook interrogates Claude at session end like a good detective: *New conventions discovered? Stale rules rotting in CLAUDE.md? Instructions that only existed to work around a model bug that's been fixed for 6 months?* It asks. You decide. Config stays fresh.

- **Giant Repo Chaos**: `/map-codebase` generates a layered table of contents so Claude knows where to look before it starts wandering. `/ignore-maintenance` audits your `.ignore` and `permissions.deny` rules so Claude stops burning tokens on `node_modules/` and `__pycache__/` like a tourist reading every street sign.

- **Config Aging (The Silent Killer)**: Rules written for last year's model can actively fight this year's. The **Maintenance Cadence** principle (baked into the global instructions) tells you to review the whole setup every 3–6 months or after major model releases. Dead weight gets cut. The config stays lean.

---

## What's Inside

| Directory / File | What lives there |
|-----------------|-----------------|
| `global-instructions.md` | The Ten Commandments — symlinked into Claude Code, Antigravity, and OpenCode alike |
| `agents/` | Subagent definitions (`adviser.md`, `explorer.md`) |
| `commands/` | Slash commands (`/scout`, `/primer`, `/map-codebase`, `/ralph-loop`, `/ignore-maintenance`, etc.) |
| `hooks/` | SessionStart / SessionEnd / PostToolUse scripts |
| `skills/` | 40+ on-demand domain skills (LangGraph, FastAPI, Qdrant, Elasticsearch, n8n, vLLM, and more) |
| `mcp/` | Canonical MCP server list (gitignored — holds live URLs/keys, synced by hand into each tool's own config) |

---

## The Holy Ritual: Symlinks

Here comes the harsh reality: your AI is dumb as a brick and doesn't magically know this wonderful repo exists. You have to shove the files down its throat using symbolic links from its actual config folders.

Open your terminal and make the links. Paths below assume you cloned this to `~/agents-hub` — adjust if yours lives elsewhere:

```bash
# IMPORTANT: If you break something, it's your own fault.

HUB=~/agents-hub

# 0. Back up your existing CLAUDE.md first (it's a real file until you do this)
cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak 2>/dev/null || true

# 1. Linking Global Instructions (The Master Brain)
# Note: CLAUDE.md → global-instructions.md — different filename, be explicit
ln -sf "$HUB/global-instructions.md" ~/.claude/CLAUDE.md

# 2. Linking Subagents (Your specialized minions: explorer, adviser)
ln -sf "$HUB/agents" ~/.claude/agents

# 3. Linking Slash Commands (So it recognizes /map-codebase and friends)
ln -sf "$HUB/commands" ~/.claude/commands

# 4. Linking Hooks (So it starts up and shuts down like a proper setup)
ln -sf "$HUB/hooks" ~/.claude/hooks

# 5. Linking Skills (40+ on-demand domain experts — don't forget this one)
ln -sf "$HUB/skills" ~/.claude/skills
```

Verify everything landed correctly:

```bash
ls -la ~/.claude/CLAUDE.md ~/.claude/agents ~/.claude/commands ~/.claude/hooks ~/.claude/skills
# Every line should show -> ~/agents-hub/...
```

### Antigravity / Antigravity IDE

Same repo, same brain — Google's IDE just uses different config paths. Link both apps:

```bash
HUB=~/agents-hub

# Antigravity (reads via ~/.gemini/config/skills, one hop further)
ln -sf "$HUB/global-instructions.md" ~/.gemini/GEMINI.md
ln -sf "$HUB/global-instructions.md" ~/.gemini/antigravity/instructions.md
ln -sf "$HUB/skills" ~/.gemini/config/skills

# Antigravity IDE
ln -sf "$HUB/global-instructions.md" ~/.gemini/antigravity-ide/instructions.md
ln -sf "$HUB/skills" ~/.gemini/antigravity-ide/skills
```

Verify:

```bash
ls -la ~/.gemini/GEMINI.md ~/.gemini/antigravity/instructions.md ~/.gemini/antigravity-ide/instructions.md ~/.gemini/config/skills ~/.gemini/antigravity-ide/skills
```

### OpenCode

OpenCode's global config lives at `~/.config/opencode/opencode.json` — not a plain markdown file, so it can't be symlinked whole. Point its `instructions` field at the same source instead:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["~/agents-hub/global-instructions.md"]
}
```

Global slash commands go in `~/.config/opencode/commands/` (one `.md` file per command — same body content as `commands/` here, but with OpenCode's own `agent:` frontmatter field instead of Claude Code's `allowed-tools`/`argument-hint`). MCP servers go in the same `opencode.json`'s `mcp` key — keep `mcp/mcp_config.json` in this repo as the canonical list and translate into each tool's schema when it changes; the three tools don't share one MCP config format.

---

## Maintenance Cadence

Every 3–6 months (or after a major model release), review:

- `global-instructions.md` — any rules compensating for model limitations that no longer exist?
- `hooks/` — any scripts automating behavior the model now does natively?
- `skills/` — any stale patterns, outdated API usage, or overlap with what the harness now does on its own?

Instructions written for last year's model can actively slow down this year's. Cut the dead weight. Keep the config lean.

---

*May your tokens be efficient and your hallucinations few.*
