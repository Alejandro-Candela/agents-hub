---
allowed-tools: Read, Glob, Bash(ls), Bash(tree), Bash(find)
argument-hint: [directory]
description: Generate a codebase map of top-level folders with one-line descriptions.
---

# Map Codebase

Generate a lightweight markdown file at the root of `$ARGUMENTS` (or current directory if not specified) listing each top-level folder with a one-line description.

## Rules

1. List only top-level directories (not files) with a one-line description of what lives there.
2. For complex subdirectories (>5 sub-folders), add a note: "run `/map-codebase <subdir>` for next level."
3. Exclude: `node_modules/`, `__pycache__/`, `.git/`, `dist/`, `build/`, generated outputs.
4. Save result as `codebase-map.md` in the target directory — commit it so all sessions start with the same table of contents.
