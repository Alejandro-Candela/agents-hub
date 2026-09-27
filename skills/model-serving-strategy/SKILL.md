---
name: model-serving-strategy
description: Model serving & inference strategy across the full size range — from a managed API for a small client, through a single self-hosted GPU box for a mid-size engagement, up to a full multi-tenant Kubernetes inference platform for enterprise/regulated clients. Use whenever someone is choosing how to serve an LLM, sizing inference infra, architecting, deploying, optimizing, hardening, or troubleshooting on-premise / sovereign-cloud LLM inference. Triggers on "which model/API should I use for this client", "deploy a 70B model", "set up vLLM / SGLang / TensorRT-LLM", "LiteLLM router / proxy", "private LLM", "self-hosted LLM", "GPU inference stack", "tokens per second / TTFT / TPOT", "speculative decoding", "prefix caching", "disaggregated serving", "tensor / pipeline / expert parallelism", "FP8 / AWQ / GPTQ / INT4 quantization", "model SLO", "GPU FinOps", "DCGM / vLLM hang / OOM / NCCL". Covers supply-chain security (model signing, SBOM, prompt-injection defense), FinOps, SRE patterns (SLO, canary, chaos), multi-tenancy, and disaggregated KV-cache architectures. For EU AI Act / GDPR / AESIA / licensing compliance, see the `ai-compliance-audit` skill — this skill references it rather than duplicating it.
disable-model-invocation: true
---

# Model Serving Strategy (2026)

> **Audience.** Anyone deciding how to serve an LLM for a client — from a solo freelance engagement for a small Spanish company through to Staff/Principal engineers building regulated-sector platforms (healthcare, defense, finance, public sector). Read §1.5 first to find your actual tier; most of this file is depth you may not need yet.
>
> **Default enterprise-tier stack (2026).** vLLM 0.7+ (or SGLang 0.4+) behind LiteLLM 1.50+, on Kubernetes with GitOps; OpenTelemetry-first observability into the LGTM stack + Langfuse; KV-cache offload via LMCache; signed models from a private OCI registry; runtime policy enforced by Kyverno/OPA. **Most engagements do not need this stack** — see §1.5.

---

## 1. Mission & scope

This skill is the canonical reference for choosing and building an inference layer that is **right-sized, fast, cheap, observable, and survivable** — for whatever client size you're actually serving. It applies whenever the deliverable is:

- Choosing between a managed API and self-hosting for a given engagement.
- A new self-hosted LLM stack (vLLM/SGLang/TensorRT-LLM + gateway), at any scale.
- A migration from public APIs to a sovereign or self-hosted deployment.
- A capacity / SLO / cost review of an existing inference platform.
- An incident postmortem on an inference outage (OOM, NCCL hang, latency regression).

If the request is *only* about training, fine-tuning, or RAG retrieval logic, this skill is not the right one — defer to a dedicated training/RAG skill and use this one for the serving leg. For governance/compliance/licensing, use `ai-compliance-audit` — this skill's own compliance section (§4) is now just a pointer to it.

---

## 1.5 Which tier do you actually need?

Pick honestly based on the actual engagement, not on what's technically impressive. Escalating a tier costs real time; over-building for a small client wastes it.

```
Small client, low volume, no real data-sensitivity concern
  (a POC, a demo, an internal tool for a <50-person company)
  → Managed API (Anthropic / OpenAI / a hosted-inference provider).
    No self-hosting at all. Skip straight to reference.md §14 for model choice,
    ignore reference.md §6-§13 entirely.

Mid-size client, moderate volume, some sensitivity
  (real but non-regulated business data, cost starting to matter,
  client wants "their own" deployment for optics or light data control)
  → Single-node self-hosted: vLLM or Ollama on one GPU box, Docker
    Compose (reference.md §8.1), basic OTel (reference.md §9, trimmed), no
    Kubernetes, no multi-tenancy machinery. reference.md §5 (supply-chain) still applies — sign
    and scan even a single-node deployment.

Enterprise / regulated client (Allianz/Siemens-tier, healthcare,
  finance, public sector, genuinely sensitive data)
  → Full stack as documented in the rest of this file: Kubernetes,
    multi-tenancy, disaggregated serving, full SRE/FinOps machinery,
    and the full ai-compliance-audit pass — not an abbreviated one.
```

Re-check the tier if the engagement's scope changes mid-project — a POC that's about to become a production deployment for a regulated client needs to move up a tier *before* go-live, not after.

---

## 2. Core philosophies (2026)

1. **Right-size before you optimize.** The most common mistake is building enterprise-tier infrastructure for a small-client engagement. Check §1.5 before doing anything else in this file.
2. **Compliance is a load-bearing requirement once the tier calls for it, not a layer bolted on everywhere.** See `ai-compliance-audit` for the actual mapping — treat audit logging, model documentation, and risk classification as P0 the moment the tier or the client's sector requires it.
3. **Security shifts left to the model itself.** Weights are executable artifacts. Sign them, scan them, pin them, and isolate them. Assume the prompt is hostile — this applies even at the single-node tier.
4. **Performance is a product of placement, not just kernels.** Disaggregated prefill/decode, prefix caching, and KV offloading often beat raw kernel tuning — but only matters once you're past the managed-API tier.
5. **Hardware-aware, not hardware-locked.** Design for H100/H200 today, validate on B200/GB200 NVL72 and MI300X. Avoid vendor lock-in at the gateway layer.
6. **FinOps from day one, at every tier.** Even a managed-API POC should track €/request from the first call, not just at enterprise scale.
7. **SRE-grade reliability — scaled to the tier.** A single-node deployment still needs a health check and a restart policy; it doesn't need canary deploys and chaos drills.
8. **Pragmatic orchestration.** Docker Compose for single-node bare-metal labs, edge installations, and most mid-tier engagements; Kubernetes + GitOps only once you cross two nodes or two tenants.

---

## 3. Reference architecture

```
            ┌──────────────────────────────────────────────────────────────┐
   Clients  │  mTLS + OIDC (Keycloak / Entra ID) + WAF + per-tenant quotas │
   ───────► │                          API Gateway                         │
            │              (Envoy / Kong / Nginx + ext_authz)              │
            └────────────────┬─────────────────────────────┬──────────────┘
                             │                             │
                       ┌─────▼──────┐               ┌──────▼──────┐
                       │  LiteLLM   │  fallback     │  Guardrails │
                       │  Router    │◄──────────────┤  (NeMo /    │
                       │  (HA, 3x)  │               │  LlamaGuard)│
                       └──┬─────┬───┘               └─────────────┘
        semantic cache    │     │   PII redact / prompt-injection
        (Redis + vec)     │     │   classifier
                          ▼     ▼
                ┌────────────────────────────────────────┐
                │         Inference engine pool          │
                │  vLLM (TP=N) │ SGLang │ TensorRT-LLM   │
                │  Disaggregated prefill / decode pools  │
                │  LMCache KV offload to CPU/NVMe/RDMA   │
                └────────┬──────────────┬────────────────┘
                         │              │
              ┌──────────▼──┐   ┌───────▼──────────┐
              │ Model store │   │ Observability    │
              │ OCI / S3 +  │   │ OTEL → Tempo /   │
              │ Sigstore    │   │ Mimir / Loki /   │
              │ + SBOM      │   │ Langfuse, DCGM   │
              └─────────────┘   └──────────────────┘
```

---

## 4. Governance & compliance — see `ai-compliance-audit`

This section used to duplicate the EU AI Act / ISO 42001 / NIST AI RMF / GDPR mapping inline. That content now lives in the `ai-compliance-audit` skill, which covers it properly — including the 2026 Digital Omnibus deadline changes, agent-specific provisions, Spain's AESIA/Ley Orgánica layer, and licensing — none of which belongs duplicated here where it would drift out of sync.

**Run that skill's audit checklist (§7) before any go-live**, at whatever depth the tier from §1.5 calls for. The sector-specific technical notes that are genuinely serving-infrastructure concerns (not general compliance) stay below:

- **Healthcare (DE)**: if output drives clinical decisions, this affects architecture, not just paperwork — anonymize per § 27 BDSG at the data layer, before it ever reaches the model.
- **Defense**: air-gapped option means no telemetry egress at the infra level — replace OTLP/HTTP exporters with file-based ones if the engagement requires it (reference.md §9 assumes network egress by default; this is the one place that assumption breaks).
- **Finance**: an exit plan from any non-EU vendor is an architecture decision (keep the gateway layer swappable, §7) as much as a contractual one.

---

## 5–15. Deep technical reference

Supply-chain & runtime security, inference engine selection/tuning, the LiteLLM gateway config, containerization (Compose/Kubernetes), observability, FinOps, reliability/SRE, MLOps, multi-tenancy, model-selection tables, capacity sizing, and the troubleshooting protocol all live in **[reference.md](reference.md)** now — this content only matters once you're past the managed-API tier (§1.5), so it loads on demand instead of sitting in every session's context.

Quick index of what's there: §5 supply-chain/security · §6 engine selection & tuning · §7 LiteLLM gateway · §8 Compose/Kubernetes · §9 observability · §10 FinOps · §11 reliability/SRE · §12 MLOps · §13 multi-tenancy · §14 model selection & capacity sizing · §15 troubleshooting.

---

## 16. Anti-patterns (reject these in review)

- ❌ Pulling weights from public Hugging Face at pod start in prod.
- ❌ `:latest` tags or unsigned model artifacts.
- ❌ A single LiteLLM replica without Postgres HA.
- ❌ Logging full prompts/completions without PII redaction or tenant scoping.
- ❌ `LITELLM_LOG=DEBUG` in prod.
- ❌ Mixing tenants on the same virtual key for "convenience".
- ❌ Spot GPUs for engines holding KV state.
- ❌ Co-locating embedding and LLM on the same GPU without explicit memory budgeting.
- ❌ Skipping the eval gate on a "hotfix" model upgrade.
- ❌ Letting a model emit Markdown to a downstream tool that auto-renders it (image-based exfil).

---

## 17. Review checklist (use before any go-live)

Scale this list to the tier from §1.5 — a managed-API POC needs almost none of it; an enterprise/regulated deployment needs all of it. **Run `ai-compliance-audit`'s own checklist alongside this one** — this list covers serving infrastructure, not compliance/licensing.

- [ ] Weights signed (cosign) and pinned by digest.
- [ ] Egress allowlist + NetworkPolicy in place.
- [ ] mTLS + OIDC at the gateway; per-tenant virtual keys.
- [ ] Guardrails (input + output) configured for the sector.
- [ ] OTEL metrics, logs, traces flowing; Langfuse capturing per-tenant.
- [ ] SLOs defined with error-budget alerts.
- [ ] Canary + rollback path tested in staging with real traffic shadow.
- [ ] DR runbook validated within the last 6 months.
- [ ] Per-tenant budget configured; cost dashboard live.
- [ ] Postgres + Redis HA, backups, PITR validated.
- [ ] Chaos drill executed and signed off.

---

## 18. References & standards

Governance/compliance standards (EU AI Act, ISO 42001, NIST AI RMF, GDPR) moved to `ai-compliance-audit` — see that skill's own references section. What stays here is infra/security-specific:

- **OWASP Top 10 for LLM Applications (2025)** — LLM01 prompt injection, LLM02 sensitive info disclosure, LLM06 excessive agency.
- **OWASP API Security Top 10 (2023)** — applies to the gateway layer.
- **Google SRE Workbook** — multi-window multi-burn-rate alerting.
- **NVIDIA DCGM, GPU Operator, NeMo Guardrails** docs.
- **vLLM** (`docs.vllm.ai`), **SGLang** (`docs.sglang.ai`), **LiteLLM** (`docs.litellm.ai`), **Langfuse** (`langfuse.com/docs`), **LMCache** (`lmcache.ai`).
- **Sigstore cosign**, **Kyverno**, **CycloneDX**.

---

## 19. Companion artifacts (suggested next steps)

Generate these at the depth §1.5's tier calls for — a managed-API POC needs none of this; scale up as the tier does:

1. `compose/` — single-node lab/mid-tier variant. Start here for anything below enterprise tier.
2. `helm/` — vLLM + LiteLLM + LMCache + DCGM Helm values. Enterprise tier only.
3. `policies/` — Kyverno + OPA bundles. Enterprise tier only.
4. `dashboards/` — Grafana JSON for the four golden dashboards.
5. `runbooks/` — incident playbooks (OOM, NCCL hang, regional failover).
6. `eval/` — Promptfoo + lm-eval-harness configs.
7. Model cards, DPIAs, and licensing artifacts — see `ai-compliance-audit`, not this skill.

Use a slide-deck-generation skill when the deliverable includes a stakeholder-facing architecture review.
