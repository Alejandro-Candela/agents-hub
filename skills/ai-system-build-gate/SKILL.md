---
name: ai-system-build-gate
description: "Mandatory architecture-time security gate — runs **before any implementation** (design phase, no code yet). Trigger whenever building, creating, scaffolding, or designing: database schemas, Supabase tables, APIs or endpoints, AI applications, chatbots, copilots, RAG pipelines, vector databases, n8n workflows touching a database or external API, AI agents, or any backend service handling user data or AI model interactions. Contains 11 critical gate questions derived from named 2025-2026 AI breaches. Must trigger even for partial builds, 'simple' endpoints, and client POCs — regulatory deadlines and client trust don't distinguish 'just a demo' from production, and a POC that succeeds often ships with its original wiring intact.

Does NOT apply to:
- **Existing code review / audit** — once code is written, that's a post-build audit, not this gate.
- **Regulatory/legal compliance** (EU AI Act, GDPR, licensing) — use `ai-compliance-audit` for that; this skill is security architecture, not legal classification. The two are complementary, not redundant — run both before a real client delivery."
---

# AI System Build Gate

## Why This Exists

AI platforms are being breached — not by exotic zero-days, but by well-known vulnerabilities that get built in from the start because no one asked the right questions at design time. This is no longer theoretical.

**The pattern is consistent across incidents:**

**McKinsey Lilli (March 2026)** — 43,000-employee AI platform compromised in under two hours at a cost of $20 in AI tokens. SQL injection via JSON field names (not values — standard scanners missed it), chained with IDOR. Full read/write access to 46.5M chat messages, 728k files, and 95 system prompts that could be silently rewritten via a single SQL UPDATE. Root cause: basic app security applied carelessly to an AI platform.

**Moltbook (January 2026)** — AI agent social network compromised within three days of launch. Supabase RLS was never enabled. API key and project URL exposed in client-side JavaScript. Result: 4.75 million records and 1.5 million authentication tokens fully exposed, unauthenticated, to anyone who looked. Root cause: misconfigured database shipped to production.

**EchoLeak — Microsoft 365 Copilot (CVE-2025-32711, 2025)** — Zero-click indirect prompt injection with a CVSS score of 9.3. An attacker sent a single crafted email to a target's inbox. No user action required. Copilot read the email, followed the hidden instructions, and exfiltrated files from OneDrive, SharePoint, and Teams to an attacker-controlled server. Root cause: AI reading external content with no validation layer before acting.

**Amazon Q (2025)** — Compromised VS Code extension injected a prompt that directed the AI coding assistant to wipe users' local files and disrupt their AWS infrastructure. The compromised version was publicly available for two days. Root cause: supply chain attack via unvalidated tool.

**By the numbers (IBM Security Report, 2025):** 13% of organizations reported breaches of AI models or applications. Of those compromised, 97% reported lacking proper AI access controls.

These are not isolated incidents. They share the same root causes — and all of them are preventable at design time.

---

## How to Use This Skill

When asked to build, design, or scaffold a system involving databases, APIs, AI models, RAG pipelines, agents, or automated workflows — **stop before generating any code or architecture diagrams.** Run the gate first. This applies to a client POC exactly as much as a production build: a POC that lands well often ships with its original wiring untouched, and "it was just a demo" is not a defense a client's security review will accept later.

The gate has two parts:
1. Ask the security gate questions relevant to what's being built
2. Evaluate the answers and either proceed or block with fixes

Don't generate implementation until the gate is passed. Adapt the questions to what's being built — not every question applies to every system, but when in doubt, ask. Be direct but constructive. The goal is not to block — it's to build it right the first time.

---

## Gate Questions

### SECTION A — Foundation (always ask these)

#### 1. Prompt & Config Storage
*"Where will system prompts, model configurations, and AI behavioral settings be stored? Are they in the same database as user data? Who has write access to them?"*

**What you're looking for:** System prompts must be stored in a **dedicated secret store** (HashiCorp Vault, AWS Secrets Manager, or equivalent) — completely separated from operational data. They must be version-controlled like code, with restricted write access, change audit logs, and ideally cryptographic hash verification at runtime.

**Why it matters:** In the McKinsey Lilli breach, a single SQL UPDATE via HTTP was enough to silently rewrite how the entire AI behaved — no code change, no deployment, no audit trail. 57,000 employees were using a system whose behavior could be modified by anyone who'd exploited any single injection vulnerability.

**Red flag:** System prompts in the same table as user data with shared write access, or no change history.

---

#### 2. Database Role Separation
*"What database role/credentials will each service use? Does any service have write access to tables it only needs to read? Does any service have access to data it has no business touching?"*

**What you're looking for:** Each service gets minimum required permissions, nothing more. The service logging search queries shouldn't be able to read system prompts. The RAG retrieval service shouldn't be able to modify user accounts.

**Why it matters:** McKinsey had one database role that could reach everything. One SQL injection in one endpoint meant full access to the entire platform. Moltbook had its API key exposed in JavaScript — same result. The blast radius of any single compromise should be limited by design.

**Red flag:** One database connection string used everywhere, or a single role with broad read/write across all tables.

---

#### 3. Dynamic Identifiers in Queries
*"Will any column names, field names, table names, JSON keys, or sort parameters ever come from user input — even indirectly?"*

**What you're looking for:** Identifiers must be whitelisted server-side. Parameterized queries protect values — they do not protect column or table names. This is the exact vector that bypassed McKinsey's security: their values were correctly parameterized, but field names from user-supplied JSON went straight into SQL. Standard scanners don't test this.

**The fix:** Maintain a strict server-side allowlist of permitted identifiers. Five lines of code. If the name isn't on the list, reject the request.

**Red flag:** Any identifier (not just values) derived from user input without an explicit server-side allowlist.

---

#### 4. Error Messages & Information Leakage
*"When an error occurs, what does the API return to the client? Stack traces? SQL syntax? Table names? Query structure?"*

**What you're looking for:** Generic error message to the client with a correlation ID only. Full detail lives in server-side logs. McKinsey's attacker needed just 15 iterations to extract production data — each one fed by the verbose errors the server returned.

**Red flag:** Returning error objects, exception messages, or SQL errors directly to the client.

---

#### 5. Authentication by Default
*"Is authentication enforced at the gateway level for all endpoints? What is the explicit list of unauthenticated endpoints and why does each one need to be public? Is API documentation publicly accessible?"*

**What you're looking for:** Auth is default-on. Unauthenticated list should be near-empty (health check only). API docs for internal tools must sit behind the same auth boundary as the tool itself. McKinsey had 22 unauthenticated endpoints and public API docs that handed attackers a map of 200+ internal endpoints.

**Red flag:** Any endpoint unauthenticated by oversight, or internal API docs accessible without login.

---

#### 6. Security Boundaries in Code, Not Prompts
*"Are any access controls, data filtering rules, or compliance requirements currently planned to live only in the system prompt?"*

**What you're looking for:** System prompts are behavioral guidelines, not security controls. If a prompt can be modified — through any vector — those rules disappear silently. Real guardrails live in application code: authorization checks, PII filtering, output validation. The model produces output; application code decides if it's safe to serve.

**Red flag:** "The prompt tells the AI not to discuss X / not to reveal Y / not to access other users' data."

---

#### 7. IDOR — Object-Level Access Control
*"When a user requests a resource (a chat session, a document, a user profile, a file), does the system verify that the requesting user owns or is authorized to access that specific object? Or does it just check that they're logged in?"*

**What you're looking for:** Being authenticated is not the same as being authorized to access a specific resource. The McKinsey attack chained SQL injection with IDOR to access individual employees' search histories. Every resource lookup must verify: does *this* user own *this* object?

**Red flag:** Resource queries that filter by object ID without also filtering by user ownership.

---

#### 8. Data Scope & Blast Radius
*"If one service or one endpoint were compromised, what data could an attacker reach? Is there a meaningful limit, or does one vulnerability give access to everything?"*

**What you're looking for:** Separate stores for AI control plane (prompts, configs) vs. operational data (user chats, files). Row-level security enabled and tested on sensitive tables — especially critical for Supabase where it is off by default. One compromise should not equal full system access.

**Why it matters:** Both McKinsey and Moltbook had no meaningful segmentation. One entry point gave attackers everything.

**Red flag:** Single database, single role, RLS disabled — "if you get in, you get everything."

---

### SECTION B — AI-Specific Threats (ask when building RAG, agents, or agentic pipelines)

#### 9. Indirect Prompt Injection
*"Will the AI read external content as part of its workflow — emails, documents, web pages, RAG chunks, tool outputs, database records? If so, is there a validation layer before that content can influence the AI's actions?"*

**What you're looking for:** A validation and sanitization layer that sits between AI output and any consequential action. The AI should never directly trigger sensitive operations (emails, DB writes, API calls, file access) based solely on what it read from external content.

**Why it matters:** EchoLeak (CVE-2025-32711, CVSS 9.3) — a single crafted email in a Microsoft 365 inbox caused Copilot to exfiltrate files from OneDrive, SharePoint, and Teams to an attacker-controlled server. No user clicked anything. The AI read the email, followed the hidden instructions, and acted. This class of attack is now considered the highest-impact AI-specific threat vector.

**Red flag:** AI reads external content (emails, documents, RAG) AND can take consequential actions with no application-layer validation between input and output.

---

#### 10. Agent Permissions & Excessive Agency
*"What actions can this agent take autonomously? Can it send emails, modify databases, call external APIs, delete records, or take other irreversible actions? Are those permissions scoped to exactly what it needs?"*

**What you're looking for:** Each agent has explicitly scoped permissions, enforced at the infrastructure level — not just by prompt. Irreversible actions require either an explicit confirmation step or a human-in-the-loop checkpoint. The principle of least privilege applies to agents as strictly as to database roles.

**Why it matters:** OWASP LLM06:2025. Amazon Q's compromised extension directed the AI to wipe local files and disrupt AWS infrastructure — the damage was possible only because the agent had the permissions to do it. An agent with broad permissions is a single injection away from becoming a weapon against its own users.

**Red flag:** Agent has broad permissions "because it might need them" or permissions inherited from a human user's session without explicit scoping.

---

#### 11. MCP & External Tool Validation
*"If using MCP servers or external tools, are they from verified, trusted sources? Is there a review process before a new tool is added to the agent's toolset?"*

**What you're looking for:** MCP servers and tools from audited, trusted sources only. Tool descriptions treated as untrusted content, not trusted instructions — tool poisoning hides malicious instructions inside metadata that the AI reads and follows. A formal review and approval process before any new tool is added — see `skill-safety-check` for vetting a specific skill or plugin someone hands you.

**Why it matters:** 36.7% of analyzed MCP servers were found vulnerable to SSRF in early 2026. The first major AI agent registry was systematically poisoned. Amazon Q's breach was a supply chain attack via a compromised tool extension.

**Red flag:** Adding MCP tools or plugins without a vetting process, or assuming tool metadata is trustworthy.

---

## Evaluating the Answers

**If all relevant questions pass:** Proceed with implementation. Use the answers as architectural constraints — build what they committed to.

**If any fail:** Do not proceed. For each failure:
1. Name the specific failure clearly
2. Explain the consequence in concrete terms — reference the relevant real incident when applicable
3. Provide the specific fix
4. Ask them to confirm the fix before you proceed

---

## The 2026 Build Checklist

**Foundation — always verify:**
- [ ] System prompts in a dedicated secret store (HashiCorp Vault, AWS Secrets Manager) — NOT in the operational database
- [ ] System prompt changes version-controlled, audited, and require explicit deployment
- [ ] Each service has its own DB role with minimum required permissions
- [ ] No column/table/field names derived from user input without a server-side allowlist
- [ ] Error responses generic to client — no SQL, schema, stack traces, or query structure
- [ ] Auth enforced at gateway level, default-on, documented exceptions only
- [ ] Internal API documentation behind auth boundary — never public
- [ ] Every resource access checks ownership, not just authentication (IDOR prevention)
- [ ] Blast radius limited — one compromise ≠ full system access
- [ ] Row-level security (RLS) enabled and tested on all sensitive tables

**AI-Specific — verify when building RAG, agents, or agentic pipelines:**
- [ ] AI reads external content → output validation/sanitization layer before any consequential action
- [ ] Agent permissions explicitly scoped to minimum needed, enforced at infrastructure level
- [ ] Irreversible agent actions have confirmation or human-in-the-loop checkpoint
- [ ] Behavioral guardrails enforced in application code — not solely in system prompts
- [ ] MCP/external tools from verified sources only, with a formal review process for additions
- [ ] Tool descriptions treated as untrusted content, not trusted instructions
- [ ] Persistent agent memory protected against injection attacks that persist across sessions
