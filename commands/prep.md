---
allowed-tools: Read, Glob, Grep, Bash(find:*), Bash(ls:*), Bash(git:*), Bash(tree:*), WebFetch, WebSearch
argument-hint: <task-description>
description: Prepare for a task by dispatching parallel scout agents to gather context from multiple domains
---

# Parallel Preparation

Task to prepare for: $ARGUMENTS

## Steps

### 1. Analyze the Task
Break the task into 2-4 independent exploration domains. Examples:
- "Add auth to API" -> domains: auth patterns, API routes, database models, middleware
- "Build RAG pipeline" -> domains: embeddings config, vector store, retrieval logic, API endpoints
- "Add monitoring" -> domains: current logging, metrics endpoints, Docker config, CI/CD

### 2. Dispatch Parallel Scouts
For each domain, launch an independent read-only subagent (`explorer` or `Explore`) with:
- A clear, specific exploration prompt
- The relevant directory or file pattern to search
- What to look for (patterns, conventions, dependencies)
- Explicit instruction: return domain findings only — do NOT write code or draft independent implementation plans

Launch ALL agents in a SINGLE message (parallel execution).

### 3. Synthesize Results (Single Orchestrator)
After all scouts report back, synthesize their findings into one unified **Preparation Brief**:

```
## Task: [one-line description]

## Domain Findings

### [Domain 1]
- [Key findings, file paths]

### [Domain 2]
- [Key findings, file paths]

## Implementation Order & Parallelizable Slices
1. [First step or parallel slice, with exact file paths and verification command]
2. [Second step or parallel slice, noting whether slices share files or can run in parallel]

## Risks
- [Gotchas, conflicts, things that could break]

## Rules & Skills to Load
- [Relevant `.claude/rules/*.md` or skills to invoke]
```

### 4. Do NOT Implement
This is preparation only. Stop after the brief.
