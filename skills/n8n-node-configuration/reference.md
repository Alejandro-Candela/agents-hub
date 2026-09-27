# n8n Node Configuration — Reference

Detailed reference material, split out of SKILL.md to stay under the 500-line skill cap.

## Detailed References

For comprehensive guides on specific topics:

- **[DEPENDENCIES.md](DEPENDENCIES.md)** - Deep dive into property dependencies and displayOptions
- **[OPERATION_PATTERNS.md](OPERATION_PATTERNS.md)** - Common configuration patterns by node type
- **[NODE_FAMILY_GOTCHAS.md](NODE_FAMILY_GOTCHAS.md)** - Silent runtime traps by family (Switch, Merge, Database, Slack, Webhook, Schedule)

---

## Summary

**Configuration Strategy**:
1. Start with `get_node` (standard detail is default)
2. Configure required fields for operation
3. Validate configuration
4. Search properties if stuck
5. Iterate until valid (avg 2-3 cycles)
6. Deploy with confidence

**Key Principles**:
- **Operation-aware**: Different operations = different requirements
- **Progressive disclosure**: Start minimal, add as needed
- **Dependency-aware**: Understand field visibility rules
- **Validation-driven**: Let validation guide configuration

**Related Skills**:
- **n8n MCP Tools Expert** - How to use discovery tools correctly
- **n8n Validation Expert** - Interpret validation errors
- **n8n Expression Syntax** - Configure expression fields
- **n8n Workflow Patterns** - Apply patterns with proper configuration

## Silent-Failure Gotchas by Node Family

Some misconfigurations pass `validate_node` and `validate_workflow` clean, run without error, and quietly do the wrong thing — `get_node` shows the fields exist but not what happens when you omit them. The high-frequency ones:

- **Switch** — no `options.fallbackOutput` ⇒ unmatched items silently dropped.
- **Merge** — `numberOfInputs` defaults to 2 (extra sources drop); `useDataOfInput` is 1-indexed vs the 0-indexed `connections.<src>.main[idx]` slot (`useDataOfInput: "N"` → `main[N-1]`).
- **Database** — `{{ }}` interpolation into `parameters.query` is SQL injection; use `$1/$2` placeholders + `options.queryReplacement`.
- **Slack** — Block Kit must be wrapped `={{ { "blocks": ... } }}` or it posts as plain text.
- **Webhook / Respond** — `responseCode` defaults to 200 even on error branches.
- **Schedule Trigger** — timezone is workflow-level (Workflow Settings), not per-rule.

Full symptom/cause/fix detail (in JSON + `n8n_update_partial_workflow` terms) in **[NODE_FAMILY_GOTCHAS.md](NODE_FAMILY_GOTCHAS.md)**.

---

---

For additional reference material, see [reference.md](reference.md).
