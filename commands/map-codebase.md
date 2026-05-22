---
allowed-tools: Read, Glob, Bash(ls), Bash(tree), Bash(find)
argument-hint: [directory]
description: Generate a codebase map of top-level folders with one-line descriptions.
---

# Map Codebase

Generate a lightweight markdown file at the root of `$ARGUMENTS` (or current directory if not specified) listing each top-level folder with a one-line description.

## Rules
1. Do NOT list every file; only list top-level directories or key entry points if necessary.
2. Provide a one-line description for each top-level folder indicating what lives there.
3. Save the result as `codebase-map.md` in the target directory so that it serves as a table of contents for subsequent sessions.
