# Agents Hub: The AI Tamer

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Harnesses supported](https://img.shields.io/badge/harnesses-3-orange.svg)](#what-is-this-actually)

Welcome to **Agents Hub**. It is a way to stop your AI agents (Claude Code, Antigravity, OpenCode, or whatever agentic CLI you have lying around) from acting like a brand new intern every single session, forgetting your conventions overnight and reinventing your folder structure out of nowhere. Not because it turns them into Senior Architects. Senior Architects do not read the docs either. Nobody does. This just gives the agent fewer excuses.

No, this is not another "10x your productivity with AI" thread. It is config. Boring, versioned, symlinked config. That happens to be the difference between an agent that remembers what you told it yesterday and one that starts from zero every morning.

---

## What is this, actually?

This is not a harness. **Claude Code, Antigravity, and OpenCode are the harnesses.** They are the runtime layer that gives a model tools and manages the context it sees. This repo is **harness configuration**: one repository, tracked in git, acting as a single source of truth (global rules, subagents, slash commands, hooks, and 40+ skills) that gets symlinked into all three.

That is the part worth stealing. Most "AI config" repos target exactly one tool and call it a day. This one drives three separate, mutually incompatible config schemas from a single set of files. Edit `global-instructions.md` once, and Claude Code, Antigravity, and OpenCode all pick it up on their next session. You explain your stack, your conventions, and your gotchas exactly once. Not once per tool, like some kind of animal.

Everything else in here (deterministic hooks instead of advisory nagging, skills that load only when needed instead of a `CLAUDE.md` the size of a novel, subagents that explore before they touch anything) is just doing what the harnesses already recommend in their own docs. None of it is exotic. Symlinked dotfiles are older than most junior engineers on your team (see `chezmoi`, `yadm`, `GNU stow`). The actual novelty here is fanning one config out across three incompatible harnesses. Not the mechanism itself.

---

## Headaches Cured (Problems Solved)

- **The Goldfish Syndrome**: Claude will no longer forget your conventions between sessions. Context loads in lean layers. Root `CLAUDE.md` covers the big picture, subdirectory files cover local rules. Only what is relevant loads. You never explain your stack to it twice, unlike your actual coworkers.

- **Blind Coding ("Oops, I deleted production")**: The **Subagent Split** pattern forces Claude to explore *first*, edit *second*. The `explorer` subagent maps a subsystem in read only mode, writes a findings file, then hands off. Shooting first and asking questions later is officially over.

- **The Grep Monkey**: No more infinite `grep` searches like a monkey banging cymbals together. Claude is forced to use **LSP** (`goToDefinition`, `findReferences`, `workspaceSymbol`) as the first option. Precision at the symbol level, not the string level. No false matches on identically named functions in different files.

- **Session Amnesia at Shutdown**: The `session-reflect.sh` hook interrogates Claude at session end like a good detective. New conventions discovered? Stale rules rotting in `CLAUDE.md`? Instructions that only existed to work around a model bug fixed six months ago? It asks. You decide. Config stays fresh.

- **Giant Repo Chaos**: `/map-codebase` generates a layered table of contents so Claude knows where to look before it starts wandering. `/ignore-maintenance` audits your `.ignore` and `permissions.deny` rules so Claude stops burning tokens reading `node_modules` and `__pycache__` like a tourist photographing every street sign.

- **Config Aging (The Silent Killer)**: Rules written for last year's model can actively fight this year's. The **Maintenance Cadence** principle, baked into the global instructions, tells you to review the whole setup every three to six months or after major model releases. Dead weight gets cut. The config stays lean, unlike most tech stacks.

---

## What's Inside

| Directory / File | What lives there |
|---|---|
| `global-instructions.md` | The Ten Commandments. Symlinked into Claude Code, Antigravity, and OpenCode alike |
| `agents/` | Subagent definitions (`adviser.md`, `explorer.md`) |
| `commands/` | Slash commands (`/scout`, `/primer`, `/map-codebase`, `/ralph-loop`, `/ignore-maintenance`, etc.) |
| `hooks/` | SessionStart, SessionEnd, and PostToolUse scripts |
| `skills/` | 40+ skills loaded on demand (LangGraph, FastAPI, Qdrant, Elasticsearch, n8n, vLLM, and more) |
| `mcp/` | Canonical MCP server list. Gitignored, because it holds live URLs and keys, synced by hand into each tool's own config |

---

## The Holy Ritual: Symlinks

Here is the part nobody puts in the marketing deck. Your AI has no idea this repository exists until you force feed it. Symbolic links are how you force feed it.

Open your terminal and make the links. Paths below assume you cloned this to `~/agents-hub`. Adjust if yours lives elsewhere:

```bash
# IMPORTANT: If you break something, that's on you.

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

Same repo, same brain. Google's IDE just uses different config paths. Link both apps:

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

OpenCode's global config lives at `~/.config/opencode/opencode.json`. It is JSON, not markdown, so it cannot be symlinked whole. Point its `instructions` field at the same source instead:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["~/agents-hub/global-instructions.md"]
}
```

Global slash commands go in `~/.config/opencode/commands/` (one `.md` file per command, same body as `commands/` here, but with OpenCode's own `agent:` frontmatter field instead of Claude Code's `allowed-tools`/`argument-hint`). MCP servers go in that same `opencode.json`'s `mcp` key. Keep `mcp/mcp_config.json` in this repo as the canonical list, and translate it into each tool's own schema by hand when it changes. The three tools do not agree on one MCP config format, because of course they do not.

---

## Maintenance Cadence

Every three to six months, or after a major model release, review:

- `global-instructions.md`: any rules compensating for model limitations that no longer exist?
- `hooks/`: any scripts automating behavior the model now does natively?
- `skills/`: any stale patterns, outdated API usage, or overlap with what the harness now does on its own?

Instructions written for last year's model can actively slow down this year's. Cut the dead weight. Keep the config lean.

---

If this saved you an afternoon of pasting the same instructions into four different YAML dialects, a star costs nothing and feeds the algorithm.

*May your tokens be efficient and your hallucinations few.*
