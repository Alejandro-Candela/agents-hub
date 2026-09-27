---
name: supabase-postgres-best-practices
description: "Supabase/Postgres best practices — use this skill whenever someone is writing SQL, designing a schema, creating Supabase tables, reviewing a query, setting up indexes, configuring RLS (Row-Level Security), or troubleshooting database performance. Trigger when someone says 'create a table', 'write a query', 'is this schema good', 'optimize this query', 'set up RLS', 'why is this slow', 'connection pooling', or any Supabase/Postgres database work. Covers RLS policies (missing RLS = critical security risk), query performance, connection management, schema design, and JSONB patterns. Use alongside ai-system-build-gate when building new systems."
license: MIT
metadata:
  source: supabase (MIT)
  version: "1.0.0"
disable-model-invocation: true
---

# Supabase Postgres Best Practices

Comprehensive performance optimization guide for Postgres, adopted from Supabase's official best practices (MIT). Contains rules across 8 categories, prioritized by impact to guide automated query optimization and schema design.

> ⚠️ **RLS is off by default in Supabase.** Every table must have Row-Level Security explicitly enabled and tested. Missing RLS = any authenticated user can read all data. This is Category 3 (CRITICAL) — check it first.

## When to Apply

Reference these guidelines when:
- Writing SQL queries or designing schemas
- Implementing indexes or query optimization
- Reviewing database performance issues
- Configuring connection pooling or scaling
- Optimizing for Postgres-specific features
- Working with Row-Level Security (RLS)

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Query Performance | CRITICAL | `query-` |
| 2 | Connection Management | CRITICAL | `conn-` |
| 3 | Security & RLS | CRITICAL | `security-` |
| 4 | Schema Design | HIGH | `schema-` |
| 5 | Concurrency & Locking | MEDIUM-HIGH | `lock-` |
| 6 | Data Access Patterns | MEDIUM | `data-` |
| 7 | Monitoring & Diagnostics | LOW-MEDIUM | `monitor-` |
| 8 | Advanced Features | LOW | `advanced-` |

## How to Use

Read individual rule files for detailed explanations and SQL examples:

```
rules/query-missing-indexes.md
rules/schema-partial-indexes.md
rules/_sections.md
```

Each rule file contains:
- Brief explanation of why it matters
- Incorrect SQL example with explanation
- Correct SQL example with explanation
- Optional EXPLAIN output or metrics
- Additional context and references
- Supabase-specific notes (when applicable)

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
