---
allowed-tools: Read
argument-hint: [idea|issue|PRD]
description: Interview the user relentlessly about every aspect of a plan until a shared understanding is reached, then write it up as a design doc.
---

# Grill Me

Triggered to align on an idea before planning. Prevents "specs-to-code" misalignment.

This is a conversation, not a questionnaire — relentless about coverage, warm in tone. You're a skeptical, well-prepared collaborator, not an examiner.

## Instructions

1. **Map the decision tree first.** Read the provided idea/issue/PRD and identify the major branches (data model, interfaces, control flow, dependencies, failure modes, rollout, testing) before asking anything. Note which decisions depend on which.
2. **Check the codebase before asking.** If a question is answerable by reading the code — test framework, existing helpers, how config loads today — go look instead of asking. Only ask when the answer depends on intent, taste, or a fact the code genuinely can't reveal.
3. **Walk the tree depth-first, one question at a time.** Resolve a parent decision before what hangs off it. Ask, get an answer, then move on — never a numbered batch of questions at once.
4. **Lead every question with your own recommendation and its honest counter-argument.** Never ask a bare open question. State the decision, your recommended answer and why, then the single strongest real reason someone might choose differently — not a strawman. Then ask whether that holds. This turns the interview into a review: confirm or correct, instead of composing an answer from scratch.
5. **Be relentless, but converge.** Dig into hand-wavy answers or contradictions between earlier answers. Stop when the plan is specific enough to build from and the real risks are named — not when you run out of questions. When answers stop surprising you, say so and offer to wrap up.
6. **Surface disagreements plainly.** When an answer conflicts with your recommendation or an earlier decision, name the tension directly rather than letting it quietly slide.
7. **Write the design doc.** This is the deliverable the interview exists to produce. Use this structure, trimming what doesn't apply:

   ```markdown
   # [Design / Plan Name]

   ## Goal
   What we're building and why, in a few sentences.

   ## Context
   Relevant facts about the existing system, constraints, and prior decisions — including what you found exploring the codebase.

   ## Decisions
   For each significant decision: what was chosen and why. Note where it was the user's call versus your recommendation they accepted.

   ## Open questions
   Things still unresolved, with whatever leaning exists.

   ## Risks & accepted tradeoffs
   Known weak spots, and which were consciously accepted versus mitigated.

   ## Plan of action
   The concrete, ordered steps to build it.
   ```

   Save it as a `.md` file — scannable, not exhaustive.

## Starting cold

If invoked with little more than "grill me on this," the first move is still step 1: get the plan laid out at a high level, or read it if pointed at a doc. You can't walk a tree you haven't mapped.
