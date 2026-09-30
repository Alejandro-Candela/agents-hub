---
name: verify
description: Run automated project verification. Detects test suites, dev servers, or linters, executes the check, inspects failure traces, and iteratively fixes issues until green. Use when verifying changes or before declaring a task complete.
---

# Automated Verification Loop

Execute an end-to-end verification loop to validate changes against running code, test suites, or live browser state before declaring work done.

## Core Principle: Verification Beats Prompting

Do not declare victory based on reasoning over code diffs. Ground-truth runtime feedback (passing tests, clean linter output, healthy HTTP response, or visual DOM state) is required to close any task.

```
Sense Stack ──> Execute Check ──> Analyze Failures ──> Surgical Fix ──> Iterate until Green
```

## 1. Stack Detection & Execution Hierarchy

Identify the project stack and choose the highest-fidelity verification mechanism available:

| Stack / Type | Primary Verification Command | Secondary / Fallback |
| :--- | :--- | :--- |
| **Python** | `uv run pytest` (or `pytest`) | `uv run mypy .` / `uv run ruff check .` |
| **Node.js / TypeScript** | `bun test` (or `vitest` / `jest`) | `bun run typecheck` / `tsc --noEmit` |
| **Frontend Web App** | Playwright MCP / `chrome-devtools` or headless test | Dev server build (`bun run build` / `npm run build`) |
| **Shell / Hooks** | `bash -n <script>.sh` + mock JSON test pipeline | ShellCheck (`shellcheck <script>.sh`) |
| **n8n / Workflow** | `validate_workflow` / `n8n_test_workflow` | JSON schema validation |

If the project has an existing project-level verify script (e.g. `npm test`, `make test`, `./scripts/verify.sh`), prioritize that.

## 2. Execution Protocol

1. **Run Check**: Run the chosen verification command via `Bash`.
2. **Observe Output**:
   - If green: Output the exact command and terminal summary. Verification is complete.
   - If red: Do not apologize or speculate. Extract the exact failure message, file, and line number.
3. **Surgical Fix**:
   - Fix the defect causing the test failure.
   - Strictly follow the rule: Touch ONLY code required to fix the issue. No drive-by refactorings.
4. **Iterate**:
   - Re-run the verification command.
   - Watch it turn green.
   - If stuck after 2 attempts, pivot strategy or consult the adviser subagent.

## 3. UI & Visual Verification Protocol

When modifying frontend components or pages:
1. Ensure the dev server is active or start it in the background (`run_in_background: true`).
2. Use **Playwright MCP** or **Chrome DevTools MCP** to:
   - Navigate to the target route (`localhost:<port>`).
   - Wait for `networkidle`.
   - Capture a screenshot or snapshot the accessibility tree.
   - Verify layout, interactive state, and console errors.
3. Verify that zero console errors or uncaught exceptions were triggered.

## 4. Definition of Done

A verification loop is successfully closed only when:
- The verification command was run and exited with code 0.
- The actual terminal output showing green/passing state is cited.
- No newly introduced regressions or linter warnings remain.
