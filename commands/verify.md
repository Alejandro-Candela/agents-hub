---
description: Run the automated verification loop (test suite, type check, build, and browser/endpoint validation)
argument-hint: [optional-target-or-test-path]
---

# Project Verification Loop

Execute the verification loop for the current workspace.

Target: $ARGUMENTS

## Instructions

1. Identify the verification mechanism for this repository (test suite, type check, build script, or visual check).
2. Execute the verification check.
3. If failures occur, analyze the error output, apply surgical fixes, and re-run until all checks pass.
4. Report the command executed and the verified passing output.
