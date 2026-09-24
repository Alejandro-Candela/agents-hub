# Agents Hub: The AI Tamer

Welcome to **Agents Hub** — the whip, the chair, and the safety net you need to stop your AI agents (Claude, Gemini, or whatever LLM you're currently abusing) from acting like confused interns on their first day and start coding like *Senior Architects who actually read the docs*.

---

## What is this for?

A single git repo that version-controls your entire Claude Code exoskeleton: global instructions, subagents, slash commands, hooks, and skills. Symlink it once, and every session starts with the same battle-tested config.

---

## Headaches Cured (Problems Solved)

- **The Goldfish Syndrome**: Claude will no longer forget your conventions between sessions. Context loads in lean layers — root `CLAUDE.md` for the big picture, subdirectory files for local rules. Only what's relevant gets loaded. No more re-explaining your stack every morning like you're meeting it for the first time.

- **Blind Coding ("Oops, I deleted production")**: The **Subagent Split** pattern forces Claude to explore *first*, edit *second*. The `explorer` subagent maps a subsystem in read-only mode, writes a findings file, then hands off. Shooting first and asking questions later is officially over.

- **The Grep Monkey**: No more infinite `grep` searches like a monkey banging cymbals together. Claude is forced to use **LSP** (`goToDefinition`, `findReferences`, `workspaceSymbol`) as the first option. Symbol-level precision. No false matches on identically named functions in different files.

- **Session Amnesia at Shutdown**: The `session-reflect.sh` hook interrogates Claude at session end like a good detective: *New conventions discovered? Stale rules rotting in CLAUDE.md? Instructions that only existed to work around a model bug that's been fixed for 6 months?* It asks. You decide. Config stays fresh.

- **Giant Repo Chaos**: `/map-codebase` generates a layered table of contents so Claude knows where to look before it starts wandering. `/ignore-maintenance` audits your `.ignore` and `permissions.deny` rules so Claude stops burning tokens on `node_modules/` and `__pycache__/` like a tourist reading every street sign.

- **Config Aging (The Silent Killer)**: Rules written for Claude 3 can actively fight Claude 4.6. The **Maintenance Cadence** principle (baked into the global instructions) tells you to review the whole harness every 3–6 months or after major model releases. Dead weight gets cut. The harness stays lean.

---

## What's Inside

| Directory / File | What lives there |
|-----------------|-----------------|
| `global-instructions.md` | The Ten Commandments — symlinked as `~/.claude/CLAUDE.md` |
| `agents/` | Subagent definitions (`adviser.md`, `explorer.md`) |
| `commands/` | Slash commands (`/scout`, `/primer`, `/map-codebase`, `/ralph-loop`, `/ignore-maintenance`, etc.) |
| `hooks/` | SessionStart / SessionEnd / PostToolUse scripts |
| `skills/` | 44 on-demand domain skills (LangGraph, FastAPI, Qdrant, Elasticsearch, n8n, vLLM, and more) |
| `mcp/` | MCP server configs (reserved for future tentacles) |

---

## The Holy Ritual: Symlinks

Here comes the harsh reality: your AI is dumb as a brick and doesn't magically know this wonderful repo exists. You have to shove the files down its throat using symbolic links from its actual config folders.

Open your terminal and make the links. Here are the actual paths to tame your beast (adjust to `.claude` or `.gemini` accordingly on your machine, since both stash their junk in your home directory):

```bash
# IMPORTANT: If you break something, it's your own fault.

# 0. Back up your existing CLAUDE.md first (it's a real file until you do this)
cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak 2>/dev/null || true

# 1. Linking Global Instructions (The Master Brain)
# Note: CLAUDE.md → global-instructions.md — different filename, be explicit
ln -sf /Users/ALEX/agents-hub/global-instructions.md ~/.claude/CLAUDE.md

# 2. Linking Subagents (Your specialized minions: explorer, adviser)
ln -sf /Users/ALEX/agents-hub/agents ~/.claude/agents

# 3. Linking Slash Commands (So it recognizes /map-codebase and friends)
ln -sf /Users/ALEX/agents-hub/commands ~/.claude/commands

# 4. Linking Hooks (So it starts up and shuts down like a proper setup)
ln -sf /Users/ALEX/agents-hub/hooks ~/.claude/hooks

# 5. Linking Skills (44 on-demand domain experts — don't forget this one)
ln -sf /Users/ALEX/agents-hub/skills ~/.claude/skills
```

Verify everything landed correctly:

```bash
ls -la ~/.claude/CLAUDE.md ~/.claude/agents ~/.claude/commands ~/.claude/hooks ~/.claude/skills
# Every line should show -> /Users/ALEX/agents-hub/...
```

### Antigravity / Antigravity IDE

Same repo, same brain — Google's IDE just uses different config paths. Link both apps:

```bash
# Antigravity (reads via ~/.gemini/config/skills, one hop further)
ln -sf /Users/ALEX/agents-hub/global-instructions.md ~/.gemini/GEMINI.md
ln -sf /Users/ALEX/agents-hub/global-instructions.md ~/.gemini/antigravity/instructions.md
ln -sf /Users/ALEX/agents-hub/skills ~/.gemini/config/skills

# Antigravity IDE
ln -sf /Users/ALEX/agents-hub/global-instructions.md ~/.gemini/antigravity-ide/instructions.md
ln -sf /Users/ALEX/agents-hub/skills ~/.gemini/antigravity-ide/skills
```

Verify:

```bash
ls -la ~/.gemini/GEMINI.md ~/.gemini/antigravity/instructions.md ~/.gemini/antigravity-ide/instructions.md ~/.gemini/config/skills ~/.gemini/antigravity-ide/skills
```

---

## Maintenance Cadence

Every 3–6 months (or after a major Claude model release), review:

- `global-instructions.md` — any rules compensating for model limitations that no longer exist?
- `hooks/` — any scripts automating behavior the model now does natively?
- `skills/` — any stale patterns or outdated API usage?

Instructions written for Claude 3.5 can actively slow down Claude 4.6. Cut the dead weight. Keep the harness lean.

---

*May your tokens be efficient and your hallucinations few.*
