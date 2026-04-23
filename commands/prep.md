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
For each domain, launch an independent Agent (subagent_type: Explore) with:
- A clear, specific exploration prompt
- The relevant directory or file pattern to search
- What to look for (patterns, conventions, dependencies)

Launch ALL agents in a SINGLE message (parallel execution).

### 3. Synthesize Results
After all scouts report back, produce a **Preparation Brief**:

```
## Task: [one-line description]

## Domain Findings

### [Domain 1]
- [Key findings, file paths]

### [Domain 2]
- [Key findings, file paths]

## Implementation Order
1. [First thing to do, with file paths]
2. [Second thing, with file paths]

## Risks
- [Gotchas, conflicts, things that could break]

## Context to Load
- @context/[relevant].md
- [Any skills to invoke]
```

### 4. Do NOT Implement
This is preparation only. Stop after the brief.
