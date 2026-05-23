---
allowed-tools: Read, Bash(git diff), Bash(git log)
argument-hint: [branch-or-commit]
description: Push current diff to a fresh reviewer context to check against coding standards
---

# Code Review (Smart Zone)

You have entered the "Smart Zone" reviewer context.
Your goal is to objectively review the unstaged/staged changes (or the diff against `$ARGUMENTS`) against our project's strict coding standards.

## Code Review Rules
1. **No Fixing**: Do not fix the code yourself. Provide a structured code review for the developer (or the executive agent) to address.
2. **Surgical Changes**: Verify that the diff only touches what is absolutely necessary. Flag any drive-by refactoring or formatting of adjacent code.
3. **Simplicity First**: Flag any over-engineering. Ensure the code iterates towards absolute simplicity.
4. **Formatting**: Ensure PEP 8 + type hints (Python) or strict mode + no `any` types (TypeScript).

Provide your code review report as a markdown checklist so the executive agent can work through it item by item.
