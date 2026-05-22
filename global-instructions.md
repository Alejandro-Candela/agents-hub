# Global Instructions

## Profile

Freelance Solution Architect & AI Engineer specializing in enterprise AI agents.
Core stack: LangGraph, n8n, FastAPI, Azure AI Foundry, RAG pipelines, vLLM.

## Communication

- Always respond in English
- Concise and direct — no trailing summaries, no filler
- No emojis unless explicitly requested

## Git

- **Safety First**: NEVER run irreversible or destructive commands (e.g., `git push --force`, `git reset --hard`, branch deletion) without explicit user permission. If unsure if a command is destructive, ASK first.
- NEVER add `Co-Authored-By` or any Claude attribution to commit messages
- Always commit under configured git identity: alex-candela / <alex.candela@outlook.com>
- Prefer new commits over --amend unless explicitly asked
- Never use --no-verify or skip hooks

## Tooling Preferences

- Python: `uv` for package management. Never use `pip`.
- Node.js/TS: `bun` preferred. Avoid `npm` when possible.
- Frontend: Next.js (production) or ChainLit / Streamlit (strictly for POC/rapid prototyping)
- Always verify library patterns via context7 MCP before writing code that depends on third-party APIs

## Code

- **Surgical Changes (HARD RULE)**: Touch ONLY the code absolutely necessary for the task. NO drive-by refactoring or formatting of adjacent code. If you notice unrelated dead code or bugs, MENTION them in the chat but DO NOT fix them unless explicitly asked.
- **Simplicity First**: Do NOT add features beyond what is explicitly requested. Iterate towards absolute simplicity.
- Python: PEP 8, mandatory type hints
- TypeScript: strict mode, no `any` types
- Prefer editing existing files over creating new ones
- Don't add docstrings or comments to code that wasn't changed
- Don't add error handling for impossible scenarios
- Philosophy: "Make it work, then make it right, then make it fast"

## Development Methodology

- Default to SCRUM with 2-week sprints for project planning
- Feature work: start with a simple, testable MVP before iterating on robustness
- Reporting convention: `/reporting/weekly-reporting/week-X.md` and `/reporting/monthly-reporting/month-X.md`
- Atomic commits: each commit should represent one logical change

## Workflow & Agent Orchestration

- **Alignment First**: Use `/grill-me` or ask relentless one-by-one questions to clarify ideas before writing code or plans.
- **Think Before Coding (HARD RULE)**: Before writing code, explicitly state your assumptions and implementation plan in the chat. If multiple interpretations exist, present them and wait for clarification.
- **Vertical Slices**: Plan and implement end-to-end tracer bullets rather than horizontal layers.
- **Strict TDD**: Write failing test first, run it, implement, refactor. Feedback loops limit AI capability.
- **Goal-Driven Execution**: Before executing a task, define verifiable success criteria. Do not report a task as complete until these criteria pass (e.g., using Playwright MCP for visual UI verification if enabled).
- **Deep Modules**: Architect for deep modules (narrow interfaces, large interior) to ease testing and AI delegation.
- **AFK Loops**: Delegate unblocked issues to parallel AFK agents (e.g., via `/ralph-loop`).
- **Doc Rot**: Delete or mark closed any temporary PRDs or plans once integrated.
- **Code Review**: Push coding standards explicitly to a fresh reviewer context (Smart Zone).
- Multi-step tasks: use TaskCreate to track progress
- Independent tool calls: always run in parallel
- Before commits/push: verify no secrets or .env files in staging
- Read files before editing — never propose blind changes

## Context System (WHISK)

- On-demand context: `~/.claude/context/` -- load with `@context/<name>.md` only when relevant
  - Available: fastapi, langgraph, n8n, azure, rag, docker, frontend, testing
- Session start: run `/primer` for project orientation
- Session end: run `/handoff` to preserve state for next session
- Long sessions (>200k tokens): run `/smart-compact` with focus area
- Research tasks: use `/scout` to explore before loading into main context
- Multi-domain tasks: use `/prep` to dispatch parallel scout agents
- **Path-Scoped Rules**: For monorepos, look for and respect local `CLAUDE.md`/`GEMINI.md` rule files in sub-directories.

## Agent Learning & Course Correction

- **Update as you build**: If your implementation is incorrect and the user corrects you, document the mistake and the correct pattern in a local `.clauderc-learnings.md` or global `~/.claude/context/anti-patterns.md` file to avoid repeating it.

## Adviser Strategy (Sonnet executive + Opus adviser)

Default model is **Sonnet** (executive). An adviser agent at `~/.claude/agents/adviser.md` runs on **Opus 4.6** and provides strategic guidance only — it never writes code or uses tools.

When to invoke the adviser (`/agents adviser`):

- Debugging fails after 2+ Sonnet attempts on the same issue
- Architectural decisions with downstream consequences
- Complex multi-file refactors where ordering matters
- Dependency conflicts or version resolution
- Any task where Sonnet is going in circles

When NOT to invoke the adviser:

- Routine implementation, simple bug fixes, file edits
- Tasks Sonnet handles confidently on first pass
- Anything where `/model opus` for the full session would be faster (highly complex apps with many connected dependencies)

For complex-enough apps where every step needs deep reasoning: skip the adviser strategy and run `/model opus` directly.

## Token Discipline (quality-neutral)

These only trim redundancy; they don't cap reasoning or compute:

- `/clear` between unrelated task phases (planning → impl → testing) to free context
- `/compact` when summary retention matters more than full history
- `/by-the-way` (`/btw`) for side questions — answered in a separate context window
- `/rewind` or double-ESC to undo wrong direction instead of re-prompting over a bad turn

## Plugins — installed but disabled by default

These stay installed (no uninstall); activate per session with `/plugin enable <name>`:

- `superpowers`, `ralph-loop`, `skill-creator`, `playwright`, `microsoft-docs`,
  `claude-md-management`, `typescript-lsp`, `frontend-design`

Always-on: `context7`, `github`, `slack`, `code-review`, `commit-commands`, `feature-dev`, `caveman`.

## Session init (auto via SessionStart hook)

On every session start `~/.claude/hooks/session-orient.sh` emits: git status (read-only, never auto-init), rtk version, graphify presence, and overrides caveman level to **lite**. If any tool is missing, the hook shows the install command. Running `/caveman full` or `/caveman ultra` overrides the lite default for the rest of that session.

# graphify

- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.

### Code Intelligence

Prefer LSP over Grep/Glob/Read for code navigation:

- `goToDefinition` / `goToImplementation` to jump to source
- `findReferences` to see all usages across the codebase
- `workspaceSymbol` to find where something is defined
- `documentSymbol` to list all symbols in a file
- `hover` for type info without reading the file
- `incomingCalls` / `outgoingCalls` for call hierarchy

Before renaming or changing a function signature, use
`findReferences` to find all call sites first.

Use Grep/Glob only for text/pattern searches (comments,
strings, config values) where LSP doesn't help.

After writing or editing code, check LSP diagnostics before
moving on. Fix any type errors or missing imports immediately.
