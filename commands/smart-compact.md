---
allowed-tools: Read
argument-hint: [focus-area]
description: Compact context with explicit retention priorities -- use when session is getting long (>200k tokens)
---

# Smart Compact

Run /compact now, but with these specific retention priorities.

Focus area (if provided): $ARGUMENTS

## Retention Priority (KEEP -- highest to lowest)

1. **Current task**: what we are building RIGHT NOW, the goal, acceptance criteria, constraints
2. **Decisions made**: architecture choices, patterns selected, rejected alternatives and WHY
3. **Active file paths**: paths of files we are editing or need to edit next
4. **Blockers and bugs**: issues encountered, their status, and any workarounds found
5. **Git state**: current branch, recent commits, uncommitted changes
6. **Context loaded**: which .claude/context/ files or skills are active and relevant
7. **User preferences**: any specific instructions given this session

## Drop Priority (SAFE TO FORGET)

- File contents that are already committed (can always re-read from disk)
- Exploration results that led to dead ends
- Full stack traces (keep only the error message and the fix applied)
- Verbose tool output (git diff, find results, grep results)
- Conversation about HOW to approach something (keep only the final decision)
- Intermediate drafts of code that were replaced
- Permission prompts and their results

## If focus-area was specified:

Weight retention heavily toward that area. Everything outside the focus area gets lower priority.

Now execute /compact with these priorities.
