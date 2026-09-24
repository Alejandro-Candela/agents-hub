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
- Prefer new commits over --amend unless explicitly asked
- Never use --no-verify or skip hooks

## Tooling Preferences

- Python: `uv` for package management. Avoid use `pip` if possible.
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
- **Subagent Split**: For large exploration tasks, spin up a read-only `/agents explorer` to map the subsystem and write findings to a file, then switch to editing with the full picture. Avoids burning the edit session's context on exploration.

## Context System (WHISK)

- Domain conventions (FastAPI, LangGraph, Docker, n8n, Azure, RAG, testing, Next.js) live in `skills/`, not a separate context directory. They load automatically when relevant.
- Session start: run `/primer` for project orientation
- Session end: run `/handoff` to preserve state for next session
- Long sessions (>200k tokens): run `/smart-compact` with focus area
- Research tasks: use `/scout` to explore before loading into main context
- Multi-domain tasks: use `/prep` to dispatch parallel scout agents
- **Path-Scoped Rules**: For monorepos, look for and respect local `CLAUDE.md`/`GEMINI.md` rule files in sub-directories.
- **Lean and Layered Context**: Keep root `CLAUDE.md` files lean for the big picture and critical gotchas. Initialize sessions in subdirectories for local conventions.
- **Codebase Legibility**:
  - Scope test and lint commands per subdirectory rather than running them globally.
  - Use `.ignore` files with `permissions.deny` rules to exclude generated files, build artifacts, and third-party code.
  - Build codebase maps (e.g., via `/map-codebase`) when directory structure doesn't clearly explain the architecture.

## Maintenance Cadence

Review CLAUDE.md files, hooks, and skills every 3–6 months or after major model releases. Instructions written for one model version can work against a newer one, especially rules compensating for reasoning or tooling limitations that no longer exist. Corrections and learned patterns belong in auto memory, not a hand-maintained file — it already persists this automatically.

## Adviser Strategy

The executive session handles implementation. An adviser agent at `~/.claude/agents/adviser.md` provides strategic guidance only — it never writes code or uses tools.

When to invoke the adviser (`/agents adviser`):

- Debugging fails after 2+ attempts on the same issue
- Architectural decisions with downstream consequences
- Complex multi-file refactors where ordering matters
- Dependency conflicts or version resolution
- Any task where the executive session is going in circles

When NOT to invoke the adviser:

- Routine implementation, simple bug fixes, file edits
- Tasks handled confidently on first pass
- Anything where switching the full session to a stronger model would be faster (highly complex apps with many connected dependencies)

For complex-enough apps where every step needs deep reasoning: skip the adviser strategy and switch the whole session to a stronger model directly.

## Plugins — installed but disabled by default

These stay installed (no uninstall); activate per session with `/plugin enable <name>`:

- `superpowers`, `ralph-loop`, `skill-creator`, `playwright`, `microsoft-docs`,
  `claude-md-management`, `typescript-lsp`, `frontend-design`

Always-on: `context7`, `github`, `slack`, `code-review`, `commit-commands`, `feature-dev`, `caveman`.

## Session init (auto via SessionStart hook)

On every session start `~/.claude/hooks/session-orient.sh` emits: git status (read-only, never auto-init), rtk version, and graphify presence. If any tool is missing, the hook shows the install command.

Caveman default mode is **lite**, set via `~/.config/caveman/config.json` (`defaultMode: "lite"`) — the plugin's own config mechanism, not a hook override. Running `/caveman full` or `/caveman ultra` switches level for the rest of that session.

## Code Intelligence

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
