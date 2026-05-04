---
allowed-tools: Read, Write, Edit, Bash
argument-hint: [issue-list]
description: Run an AFK implementation loop grabbing independent vertical slice issues.
---

# Ralph Loop (AFK Agent Orchestrator)

Run an autonomous implementation loop over unblocked tasks using AFK strategies (Sand Castle pattern).

## Instructions
1. Review the provided backlog of issues/tasks.
2. Pick the next unblocked task. **Prioritize vertical slices (tracer bullets) over horizontal layers.**
3. Implement using strict TDD (Red-Green-Refactor). Write the failing test first, run it, then make it pass.
4. Run local feedback loops (tests, type-checks) to avoid "coding blind".
5. Once completed, output the commit or patch ready for the reviewer agent (ensure review happens in a fresh context).
6. Repeat until the backlog is empty or blocked.
