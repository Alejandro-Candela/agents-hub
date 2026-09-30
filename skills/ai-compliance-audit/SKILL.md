---
name: ai-compliance-audit
description: Audits an AI/agent system or codebase against EU AI Act obligations, Spain's national implementation (AESIA, Ley Orgánica de IA), GDPR/AEPD, model and dependency licensing, and vendor terms of service. Use whenever someone asks "are we compliant", "can we ship this", "check the licenses", "what's our EU AI Act risk classification", "is this agent high-risk", "review this vendor's ToS", or before any client delivery / production go-live involving an AI system in or targeting the EU or Spain. Triggers on "EU AI Act", "AESIA", "AI compliance", "GDPR AI", "model license", "open weight license", "terms of service review", "provider vs deployer", "high-risk AI system", "conformity assessment", "AI regulation Spain/España".
---

# AI Compliance & Licensing Audit (2026)

> **This is a technical/architectural aid, not legal advice.** It tells you what to check and where the current thresholds sit as of this writing. A qualified lawyer must sign off on any actual risk classification, conformity assessment, or contract review before you rely on it with a client. Regulatory dates in this space move — the Digital Omnibus pushed the EU AI Act's own high-risk deadlines back mid-2026 without warning. **Re-verify every date and threshold in this file before quoting it to a client**; do not treat anything here as frozen fact.

> **Audience.** Anyone shipping an AI system, agent, or model-backed product to a client in the EU or Spain — from a solo freelance POC to an enterprise production deployment. Scale the depth of the audit to the actual stakes: a synthetic-data demo for a 10-person client needs a lighter pass than a system touching real insurance or health data.

---

## 1. Mission & scope

This skill is the canonical place for compliance/licensing checks so they are done **once and referenced**, not re-derived (or silently skipped) per project. It covers:

- EU AI Act risk classification and obligations (provider vs. deployer, GPAI, agent-specific provisions)
- Spain's national layer (AESIA, Ley Orgánica de IA, competent-authority map)
- GDPR / AEPD data-protection overlay
- Model and dependency **licensing** (open-weight ≠ open-source; OSS license compatibility)
- Vendor **terms of service** review (API providers, sub-processors, data-training clauses)

If the request is about **inference infrastructure sizing or serving architecture**, defer to `model-serving-strategy` — that skill references this one for the compliance mapping rather than duplicating it.

---

## 2. Core philosophies

1. **Document once, reference everywhere.** A compliance mapping copy-pasted into three skills goes stale in two of them the moment the law changes. This file is the one place it lives.
2. **Deployer vs. provider is the single most consequential question.** Get this wrong and every downstream obligation is wrong. Ask it first, always.
3. **"Open" is a marketing word, not a license.** Check the actual license text. "Open-weight" and "open-source" are not the same thing, and vendors blur this on purpose.
4. **Autonomy is a risk multiplier, not a footnote.** An agent that can call tools, spawn sub-agents, or act without a human in the loop is treated more strictly than a passive assistant — this is explicit in the Act's own risk-management mandate.
5. **Date every claim.** This file is dated to September 2026 research. A regulatory delay, a new implementing act, or a vendor license change can invalidate any specific number here without touching the structure. Re-check before you rely on it.
6. **Scale the audit to the stakes**, not to a fixed checklist length. A synthetic-data internal demo and a system touching real financial or health data are different audits, even if both use this same skill.

---

## 3. EU AI Act — current state (as of Sept 2026)

### 3.1 Timeline — corrected for the Digital Omnibus delay

The original schedule pushed all high-risk obligations to apply from August 2026. **That changed.** The Commission's Digital Omnibus on AI (proposed Nov 19, 2025; political agreement May 7, 2026; **Regulation (EU) 2026/1744**, in force **July 27, 2026**) revised the milestones:

| Date            | What actually applies                                                                                                                                                                                                                             |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Aug 1, 2024     | Act enters into force                                                                                                                                                                                                                             |
| Feb 2, 2025     | Prohibited practices (Art. 5) + AI literacy obligations                                                                                                                                                                                           |
| Aug 2, 2025     | GPAI provider obligations begin                                                                                                                                                                                                                   |
| **Aug 2, 2026** | **Article 50 transparency obligations** (disclosure that content is AI-generated/AI-interacted) + full Commission/AI Office enforcement tooling for GPAI. **NOT** full high-risk enforcement — that was the pre-Omnibus expectation and it moved. |
| Dec 2, 2026     | Art. 50(2) transition period ends for generative systems already on the market pre-Aug-2026; new Art. 5 prohibitions (non-consensual intimate imagery, CSAM) apply                                                                                |
| **Dec 2, 2027** | **High-risk obligations for Annex III systems** (the common case: employment, credit/insurance scoring, law enforcement-adjacent, etc.)                                                                                                           |
| **Aug 2, 2028** | **High-risk obligations for Annex I systems** (AI as a safety component of a regulated product)                                                                                                                                                   |

**Practical read for a POC/delivery today:** you are not yet under full high-risk enforcement even for a genuinely high-risk use case — but the _documentation and architecture_ obligations (audit trails, risk management, human oversight) are exactly what a client's own procurement/security review will ask about long before the legal deadline bites, and building them in from the POC stage is far cheaper than retrofitting before Dec 2027. Treat the deadline table as a compliance floor, not a target.

### 3.2 Risk classification — do this first, every engagement

```
Is the system prohibited outright (Art. 5)?
  → social scoring, real-time biometric ID in public (with narrow LE exceptions),
    emotion inference in workplace/education, manipulative/subliminal techniques
  → STOP. Cannot deploy in the EU regardless of client request.

Is it Annex III high-risk?
  → employment (hiring/firing/promotion), credit/insurance scoring,
    law-enforcement-adjacent, migration/asylum, education access/scoring,
    critical infrastructure safety, biometric categorization
  → Full Chapter III obligations apply from Dec 2, 2027. Build the audit
    trail and human-oversight design NOW; do not wait for the deadline.
  → NOTE: a component that "merely assists users or optimises performance
    without creating health or safety risks" is explicitly carved OUT of
    high-risk under the Omnibus's narrowed "safety component" definition —
    do not over-classify a genuinely assistive feature.

Is it Annex I high-risk (safety component of a regulated product)?
  → machinery, medical devices, vehicles, etc. under existing product law
  → Full obligations from Aug 2, 2028.

Is it GPAI (general-purpose AI model, not a deployed system)?
  → training compute > 10^25 FLOPs → "systemic risk" tier, stricter obligations
  → Provider obligations already active since Aug 2025.

None of the above, but it interacts with a person (chatbot, generated content)?
  → Art. 50 transparency: disclose AI involvement. Active now (Aug 2026).

Otherwise → minimal-risk. No Chapter III obligations, but Art. 50 and
  general governance hygiene still apply if it's client-facing.
```

### 3.3 Provider vs. deployer — get this right first

- **Provider**: develops the system or substantially modifies one, places it on the market under its own name.
- **Deployer**: uses the system in its own operations without substantial modification.
- **The provider remains liable even after handoff**, unless the deployer substantially modified the system.
- **The line blurs for agents specifically**: a deployer who configures an agent with broad tool-calling rights, autonomous decision scope, or the ability to spawn sub-agents may be taking on provider-level obligations regardless of what the contract says. There is no bright-line test published for exactly where this tips — flag it explicitly to the client rather than assume your contract protects you.

**As a freelance consultant building the system for a client**: you are very likely acting as (or alongside) the **provider** when you build and configure the agent's autonomy, even though the client is the one deploying it. Say this out loud in the engagement scoping, not after something goes wrong.

### 3.4 Agent-specific provisions — this is the "normativa de agentes" section

Autonomous agents (plan → act → observe loops, tool-calling, multi-step decisions) are treated more strictly than passive assistants because autonomy is explicitly a risk-classification factor:

- **Article 9** (risk management) — the process must consider the system's level of autonomy as a characteristic. More autonomy → more rigorous risk management expected.
- **Article 12** (record-keeping) — multi-step agent decision chains need **per-decision audit trails**, not just a final-output log. If your agent takes 6 tool calls to reach an answer, log the reasoning at each step, not just the last one.
- **Article 14** (human oversight) — the design must include a functional way for a human to intervene or stop the system — a real "stop button," not a theoretical one. For an autonomous agent this means: can a human actually halt it mid-task, and does the architecture make that meaningfully possible (not just "add a cancel button that isn't wired to anything")?
- **Multi-agent systems = one AI system.** The May 2026 Digital Omnibus clarification: a multi-agent deployment (orchestrator + sub-agents) is regulated as a **single AI system**, not as N separate systems with N separate obligation chains. This resolves what used to be a real ambiguity — don't over-engineer separate compliance docs per sub-agent.
- **Liability**: AI has no legal personality: liability for an agent's errors, data breaches, or economic damages rests with the company using it, foreseeable or not. Beyond the AI Act itself, the **Product Liability Directive** can also apply where autonomous agent actions cause damage.

### 3.5 GPAI thresholds

- Training compute > 10^25 FLOPs → "systemic risk" GPAI tier (Llama 3.1 405B, DeepSeek-V3 are around this threshold — check the specific model's published figures, don't assume from the model name).
- Document: training data summary (reference the upstream provider's published summary — required for AI Act compliance regardless of high-risk status), capability evaluations, and — new emphasis for 2026 — **licensing of training data**, since providers of high-risk systems must document training-data sourcing and licensing once the high-risk deadlines land.

---

## 4. Spain — national layer

### 4.1 AESIA

**AESIA** (Agencia Española de Supervisión de Inteligencia Artificial) — created by RD 729/2023, headquartered in A Coruña. Spain was the first EU country to stand up a dedicated AI supervision agency, and ran the **EU's first AI regulatory sandbox**, which closed in June 2026 (~€4.3M funded via the Plan de Recuperación). The sandbox produced practical guidance (risk management, quality systems, human oversight, data governance, transparency, cybersecurity, recordkeeping) — **non-binding, but a genuinely useful practical reference** since it exists precisely to translate the Act's legal obligations into procedures, which most other EU countries don't have yet.

### 4.2 Ley Orgánica de IA (national implementing law, in progress through 2026)

Spain's national law adapting the AI Act into Spanish legal order, defining authorities, sanctions, claims processes, sandboxes, and public-sector obligations. **Competent-authority split** (as currently drafted):

| Domain                                               | Authority                                                                      |
| ---------------------------------------------------- | ------------------------------------------------------------------------------ |
| Annex III systems generally (notifying authority)    | Dirección General de Inteligencia Artificial                                   |
| Biometrics, data, borders                            | AEPD (retains a decisive role)                                                 |
| Justice-sector systems                               | CGPJ                                                                           |
| Financial / insurance sector                         | Existing sectoral supervisors (Banco de España, DGSFP) keep their competencies |
| Single point of contact for supervision coordination | AESIA                                                                          |

**Practical implication**: for a use case touching personal data (basically anything RAG/agent-based that isn't pure internal document search), **AEPD** involvement is likely regardless of which sector-specific authority also applies — GDPR and the AI Act layer on top of each other, they don't replace each other.

### 4.3 GDPR / AEPD overlay — don't forget this is still separately in force

The AI Act does not replace GDPR. For any system processing personal data (which includes most RAG-over-client-documents and any customer-facing agent):

- Lawful basis for processing (Art. 6 GDPR) must be established independently of AI Act classification.
- DPIA (Data Protection Impact Assessment) is very likely required for a system profiling individuals or making automated decisions with legal/similarly-significant effect (Art. 35 GDPR) — this is a **separate document** from the AI Act's own risk assessment, though they share a lot of the same analysis.
- **Right to erasure** interacts badly with caches: semantic caches, KV-cache offload, and vector stores must be tenant/subject-scoped so a deletion request can actually be honored, not just "deleted from the primary DB while a stale copy lives in a cache for 30 days."

---

## 5. Licensing audit

### 5.1 The core trap: "open weight" ≠ "open source"

Many models marketed as "open" release only the weights, not the training data, and attach commercial-use restrictions. **Check the license text itself, never the vendor's marketing label.**

| License family                     | Commercial use                                                                                                     | Gotcha                                                                                                                                                                    |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Apache 2.0**                     | Unrestricted                                                                                                       | ~38% of new Hugging Face releases in 2026 use this. Genuinely permissive — but check the patent clause against your own IP if you're building something patent-sensitive. |
| **MIT**                            | Unrestricted                                                                                                       | Simplest, attribution only.                                                                                                                                               |
| **Llama Community License** (Meta) | Free below a **700M MAU cap** (as of mid-2025 figure — re-verify, these caps move)                                 | Not a standard OSS license. Crossing the MAU threshold requires a separate commercial agreement with Meta.                                                                |
| **Qwen / Tongyi Qianwen**          | Free below a MAU/revenue threshold                                                                                 | Similar scale-gated pattern to Llama; check the current published number, not a cached figure.                                                                            |
| **Kimi K2/K3, MiniMax-M2**         | Free below a revenue threshold (Kimi K3: ~$20M aggregate 12-month revenue trigger, per Moonshot's published terms) | Also imposes a **branding/naming requirement** ("Built with X", displaying the model name in-product) — a compliance obligation, not just a courtesy.                     |
| **Gemma Terms of Use**             | Custom, has use-restrictions                                                                                       | Read the specific prohibited-use list; it's not Apache-equivalent despite Google's framing.                                                                               |
| **OpenRAIL-M**                     | Use-case restricted                                                                                                | Explicitly bars certain use cases (varies by model) — check against your actual application, especially anything touching decisions about people.                         |
| **CC-BY-NC**                       | **Research only**                                                                                                  | Not commercially usable at all. Seen occasionally on smaller research releases — verify before any client-facing use.                                                     |

**Real failure modes already documented in 2026**: a developer accidentally distributed a Llama 2 fine-tune under MIT instead of the required custom license and received a cease-and-desist from Meta. Another spent three weeks resolving an Apache 2.0 patent-clause conflict with their own IP portfolio _after_ shipping. Check licenses before you build on a model, not after a client asks.

### 5.2 Dependency / OSS license audit (the codebase itself, not just the model)

- Run a license scanner (`pip-licenses`, `license-checker` for npm, or a SCA tool) over the actual dependency tree before delivery — don't eyeball `package.json`.
- **GPL/AGPL contamination risk**: a GPL-licensed dependency in a proprietary client deliverable can force disclosure obligations you didn't intend. AGPL specifically also triggers on network use (SaaS), not just distribution — relevant if the POC becomes a hosted product.
- Flag anything with a "non-commercial," "research-only," or custom license in the dependency tree — these turn up more often in ML tooling than in typical web-app dependencies.

### 5.3 What to actually deliver as the licensing artifact

A short `LICENSES.md` per project: model(s) used + license + any threshold/branding obligation, plus a dependency-scan summary. This is cheap to produce and is exactly the kind of artifact a client's procurement team will ask for and be positively surprised you already have.

---

## 6. Terms of service / vendor contract review

Before building on any third-party model API or SaaS AI vendor, check:

- **Data usage for training** — does the vendor's ToS allow them to train on your (or your client's) submitted data? Most enterprise-tier API plans opt out by default; verify it's actually the tier you're using, not just the vendor's general marketing claim.
- **Data retention & region** — where is data processed and stored, and for how long? This feeds directly into the residency/sovereignty question from the client engagement (see the delivery-model discussion — residency = where data sits, sovereignty = whose law governs it; a vendor ToS answers the first, not always the second).
- **Sub-processor disclosure** — under GDPR Art. 28, a processor (the vendor) must disclose its own sub-processors. If the vendor's ToS doesn't name them, that's a gap to flag before signing anything on the client's behalf.
- **Commercial-use restrictions and liability caps** — read the actual limitation-of-liability clause; for a client engagement built on a third-party API, your exposure if the vendor has an outage or data incident is usually capped far below the damage it could cause the client.
- **SLA** — does it exist, and does it match what you're promising the client? Don't promise an SLA tighter than what your own vendor stack actually offers you.

---

## 7. Audit checklist — run before any client delivery or production go-live

- [ ] Risk classification recorded (prohibited / Annex III / Annex I / GPAI / minimal) with the reasoning written down, not just the label.
- [ ] Provider vs. deployer role documented for this specific engagement — in writing, in the contract/SOW, not assumed.
- [ ] If the system is agentic: autonomy level assessed against Art. 9; per-decision audit trail designed (Art. 12); a real, wired human-override path exists (Art. 14).
- [ ] If multi-agent: confirmed it's documented and risk-assessed as one system, not fragmented per sub-agent.
- [ ] GDPR lawful basis identified; DPIA done or explicitly scoped-out with reasoning, for anything touching personal data.
- [ ] Right-to-erasure path checked against every cache/vector-store layer, not just the primary DB.
- [ ] Every model in use: license identified by reading the actual license text; MAU/revenue thresholds checked against realistic projected scale; branding obligations noted if any.
- [ ] Dependency tree scanned for GPL/AGPL/non-commercial licenses; none present in a client deliverable without an explicit, documented decision to accept that.
- [ ] Vendor ToS reviewed for any third-party model/API used: training-on-data opt-out confirmed, data region confirmed, sub-processors disclosed.
- [ ] `LICENSES.md` artifact produced and handed over with the deliverable.
- [ ] If the client is Spain-based or the system serves Spanish users: AEPD's role noted where personal data is involved; AESIA's published sandbox guidance checked for a directly relevant sector fiche if one exists.
- [ ] A lawyer has actually looked at this before it's presented as "compliant" to the client — this skill informs that conversation, it doesn't replace it.

---

## 8. Anti-patterns (reject these in review)

- ❌ Classifying risk from the model name or vendor marketing ("it's just an assistant") instead of from what the system actually does.
- ❌ Treating "open" in a model's name or README as proof of unrestricted commercial use.
- ❌ Logging only the final output of a multi-step agent and calling it an audit trail.
- ❌ A "stop button" in the UI that isn't actually wired to halt the running agent.
- ❌ Assuming a client's existing GDPR program covers the AI Act too — it covers the data-protection layer, not the AI-specific obligations.
- ❌ Quoting a compliance deadline from memory instead of checking whether it's been amended (this exact mistake happened earlier in this file's own drafting — re-verify).
- ❌ Shipping a client deliverable with a GPL-licensed dependency nobody checked for.
- ❌ Presenting this skill's output as legal sign-off. It is not one.

---

## 9. References & standards

- **EU AI Act** — Regulation (EU) 2024/1689, as amended by the Digital Omnibus, **Regulation (EU) 2026/1744** (in force July 27, 2026). Primary source: `artificialintelligenceact.eu` and the Commission's own AI Act service desk (`ai-act-service-desk.ec.europa.eu`).
- **AESIA** — Real Decreto 729/2023; sandbox outputs and sector guides published by AESIA (non-binding but practically useful).
- **Ley Orgánica de IA** (Spain) — national implementing legislation, in progress through 2026; check its current status before citing specific article numbers, it wasn't finalized as of this writing.
- **GDPR** (Regulation (EU) 2016/679) + **LOPDGDD** (Spain's national data-protection law) — still separately in force alongside the AI Act.
- **Product Liability Directive** — relevant overlay for autonomous-agent damage claims.
- Open-weight license texts: always the vendor's own published license page, never a secondary summary (including this file) — licenses and their thresholds change without much notice.

This file was researched in September 2026. Treat every date, threshold, and euro figure as a starting point for verification, not a citable fact on its own.
