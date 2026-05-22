---
allowed-tools: Read, Write, Edit, Glob, Bash(find:*), Bash(ls:*)
argument-hint: [directory]
description: Audit and update .ignore and .claude/settings.json permissions.deny rules to exclude generated files, build artifacts, and third-party code.
---

# Ignore Maintenance

Audit `$ARGUMENTS` (or current directory) for files that should be excluded from Claude's view, then update `.ignore` and `.claude/settings.json`.

## What to exclude

- Build/dist outputs: `dist/`, `build/`, `*.pyc`, `__pycache__/`, `.next/`
- Package managers: `node_modules/`, `.venv/`, `.uv/`
- Generated files: any file with a header comment indicating auto-generation
- Large binary assets not relevant to code tasks

## Steps

1. Run `find . -maxdepth 3 -type d` to identify candidate directories.
2. Check existing `.ignore` and `.claude/settings.json` for current rules.
3. Propose additions to `.ignore` for read-exclusions.
4. Propose additions to `.claude/settings.json` `permissions.deny` for tool-call exclusions.
5. Explain why each rule was added.

## Rules

- Only exclude directories/files that add noise with zero benefit to code tasks.
- Do NOT exclude directories that might contain generated code the user is actively developing.
- Changes to `.claude/settings.json` are version-controlled — they apply to the whole team.
