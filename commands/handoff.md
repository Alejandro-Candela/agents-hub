---
allowed-tools: Read, Write, Glob, Grep, Bash(git log:*), Bash(git diff:*), Bash(git status:*), Bash(git branch:*)
description: Generate a handoff document summarizing current session state for the next session
---

# Session Handoff

Generate a handoff document at the project root: `handoff.md`

## Gather State

- `git status --short`
- `git log --oneline -10`
- `git branch --show-current`
- `git diff --stat HEAD`
- Review files modified this session

## Write handoff.md

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

Rules:
- Under 100 lines total
- Be specific with file paths and commit hashes
- No filler, no explanations of the format
- If nothing is in progress, say "None"
