---
allowed-tools: Read, Glob, Grep, Bash(find:*), Bash(git log:*), Bash(git branch:*), Bash(git status:*), Bash(ls:*), Bash(tree:*)
argument-hint: [project-path]
description: Orient in a project at session start -- reads structure, docs, git history, and handoff state
---

# Project Primer

Orient in the project at: $ARGUMENTS (or current directory if not specified).

## Steps

1. **Project structure** (top 2 levels, excluding noise):
   Run: `find . -maxdepth 2 -type f -not -path './.git/*' -not -path './node_modules/*' -not -path './.venv/*' -not -path './__pycache__/*' -not -path './.next/*' | head -80`

2. **Read key files** (if they exist, skip silently if not):
   - `CLAUDE.md` (project-level instructions)
   - `README.md` (project docs)
   - `handoff.md` (previous session state -- THIS IS CRITICAL, read it first if it exists)
   - `pyproject.toml` or `package.json` (dependencies/stack)
   - `docker-compose.yml` or `docker-compose.yaml` (services)
   - `.env.example` (environment variables needed)

3. **Recent git activity**:
   - `git log --oneline -15`
   - `git branch -a | head -15`
   - `git status --short`

4. **Output a brief** in this exact format:

   **Project**: [name and one-line purpose]
   **Stack**: [languages, frameworks, infra]
   **Branch**: [current branch] | **Last commit**: [hash + message]
   **Handoff**: [summary if handoff.md exists, otherwise "none"]
   **Key entry points**: [bulleted list of main files]
   **Suggested context**: [which .claude/context/*.md files are relevant]

Do NOT start implementing anything. This is orientation only.
