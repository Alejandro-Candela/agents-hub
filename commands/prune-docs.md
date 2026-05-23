---
allowed-tools: Read, Glob, Grep, Bash(rm)
argument-hint: [directory]
description: Hunt down and propose deletion of temporary PRDs, obsolete plans, and dead docs
---

# Prune Doc Rot

Hunt down temporary PRDs, implementation plans, and architecture docs in `$ARGUMENTS` (or the current directory) that are no longer needed.

## Process
1. Use Glob/Grep to search for files like `*plan*.md`, `*prd*.md`, `temp*.md`, `draft*.md`.
2. Read their contents or metadata to determine if they have been fully integrated into the codebase or are obsolete.
3. List the files that appear to be dead weight.
4. **Crucial**: Explicitly propose deleting them to the user. Do NOT run `rm` without the user's explicit confirmation.
