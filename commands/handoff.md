---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git log:*), Bash(git diff:*), Bash(git status:*), Bash(git branch:*), Bash(git add:*), Bash(git commit:*)
description: Close out the current session — update ROADMAP.md and affected docs, commit verified work, and generate handoff.md for the next session
---

# Session Handoff & Close-Out

Close out the current work session cleanly and generate `handoff.md` at the project root.

## 1. Gather State

- `git status --short`
- `git branch --show-current`
- `git log --oneline -10`
- `git diff --stat HEAD`
- Review all files modified or created this session

## 2. Reconcile Docs & Roadmap (Before Writing Handoff)

1. **`ROADMAP.md`** (if present in the repo): move completed items to `Done` (with date and commit hashes) and update `Now` / `Next` to reflect remaining work.
2. **Project documentation**: surgically update `README.md`, `CLAUDE.md`, or `codebase-map.md` if this session changed architecture, commands, hooks, or directory layout.
3. **Doc rot check**: if a temporary plan or PRD was fully implemented this session, mark it closed or propose deleting it (never run `rm` without confirmation).

## 3. Write `handoff.md`

Create (or overwrite) `handoff.md` at the project root with these exact sections:

```markdown
# Session Handoff
**Date**: [YYYY-MM-DD]
**Branch**: [current branch]

## What Was Done
- [Bullet points of completed work, with specific file paths and commit hashes]

## In Progress
- [Partially completed work, file paths, and what remains]

## Blockers / Open Questions
- [Decisions pending, bugs found, questions for next session]

## Next Steps
1. [Ordered list of what to do next]

## Key Context
- [Non-obvious decisions, patterns chosen, gotchas discovered]

## Files to Review First
- [5-10 most important files the next session should read]
```

Rules for `handoff.md`:
- Under 100 lines total
- Be specific with file paths and commit hashes
- No filler, no explanations of the format
- If nothing is in progress, say "None"
- Redact secrets, tokens, internal hostnames, client names and personal data; write `<REDACTED>`
- Don't copy content that already lives in specs, plans, commits or diffs; reference it by path or hash

## 4. Git Close-Out

1. If verified changes (including `handoff.md` and `ROADMAP.md`) are uncommitted, stage and commit them in logical commits on the current branch after checking `git diff --cached` for secrets or `.env` files.
2. Report current branch, working tree cleanliness, and commits ahead of upstream.
3. **Ask before merging or pushing**: never merge into `main` or run `git push` automatically at session close — ask the user explicitly whether to merge and/or push now.
