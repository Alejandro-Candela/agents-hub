---
name: enterprise-model-serving
description: Enterprise-grade Model Serving & AIOps skill. Use whenever someone is architecting, deploying, optimizing, hardening, or troubleshooting on-premise / sovereign-cloud LLM inference infrastructure at scale. Triggers on "deploy a 70B model", "set up vLLM / SGLang / TensorRT-LLM", "LiteLLM router / proxy", "private LLM", "self-hosted LLM", "GPU inference stack", "tokens per second / TTFT / TPOT", "speculative decoding", "prefix caching", "disaggregated serving", "tensor / pipeline / expert parallelism", "FP8 / AWQ / GPTQ / INT4 quantization","EU AI Act compliant inference", "ISO 42001", "model SLO", "GPU FinOps", "DCGM / vLLM hang / OOM / NCCL". Covers governance (EU AI Act, ISO 42001, NIST AI RMF, GDPR), supply-chain security (model signing, SBOM, prompt-injection defense), FinOps, SRE patterns (SLO, canary, chaos), multi-tenancy, and disaggregated KV-cache architectures for regulated EU sectors.
disable-model-invocation: true
---

# Enterprise Model Serving & AIOps (2026)

> **Audience.** Staff/Principal engineers, ML platform teams, and AI architects delivering on-premise or sovereign-cloud LLM inference for regulated clients (healthcare, defense, finance, public sector).
>
> **Default stack (2026).** vLLM 0.7+ (or SGLang 0.4+) behind LiteLLM 1.50+, on Kubernetes with GitOps; OpenTelemetry-first observability into the LGTM stack + Langfuse; KV-cache offload via LMCache; signed models from a private OCI registry; runtime policy enforced by Kyverno/OPA.

---

## 1. Mission & scope

This skill is the canonical reference for designing a production inference platform that is **fast, cheap, observable, compliant, and survivable**. It applies whenever the deliverable is:

- A new self-hosted LLM stack (vLLM/SGLang/TensorRT-LLM + gateway).
- A migration from public APIs to a sovereign deployment.
- A capacity / SLO / cost review of an existing inference platform.
- An incident postmortem on an inference outage (OOM, NCCL hang, latency regression).

If the request is *only* about training, fine-tuning, or RAG retrieval logic, this skill is not the right one — defer to a dedicated training/RAG skill and use this one for the serving leg.

---

## 2. Core philosophies (2026)

1. **Compliance is a load-bearing requirement, not a layer.** EU AI Act obligations for general-purpose AI models start applying in production deployments in 2026. Treat audit logging, model documentation, and risk classification as P0 features, not afterthoughts.
2. **Security shifts left to the model itself.** Weights are executable artifacts. Sign them, scan them, pin them, and isolate them. Assume the prompt is hostile.
3. **Performance is a product of placement, not just kernels.** Disaggregated prefill/decode, prefix caching, and KV offloading often beat raw kernel tuning. Measure TTFT and TPOT separately.
4. **Hardware-aware, not hardware-locked.** Design for H100/H200 today, validate on B200/GB200 NVL72 and MI300X. Avoid vendor lock-in at the gateway layer.
5. **FinOps from day one.** Every token has a cost in € / GPU-hour / kWh. Tag, meter, and budget per tenant.
6. **SRE-grade reliability.** Defined SLOs, error budgets, circuit breakers, and chaos drills — same standard as any other Tier-1 service.
7. **Pragmatic orchestration.** Docker Compose for single-node bare-metal labs and edge installations; Kubernetes + GitOps the moment you cross two nodes or two tenants.

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

## 4. Governance & compliance (EU-first)

### 4.1 EU AI Act mapping (effective 2026)

For every deployed model, record in a **Model Card + Technical Documentation Pack** stored in Git alongside the manifest:

- **Risk classification.** Prohibited / High-risk / Limited-risk / Minimal. Healthcare and defense use cases are typically high-risk → Articles 9–15 obligations apply.
- **Provider vs. deployer role.** Your organization is usually the **deployer** when integrating third-party open-weights models. Document obligations under Article 26.
- **GPAI thresholds.** Track whether the model qualifies as GPAI with systemic risk (training compute > 10^25 FLOPs). Llama 3.1 405B and DeepSeek-V3 are at the threshold; document accordingly.
- **Training data summary.** Reference the upstream provider's published summary; never strip it.
- **Capability evaluations.** Store eval results (lm-eval-harness, MMLU, MT-Bench, internal regulated-sector benches) per release.
- **Post-market monitoring.** Drift, harmful-output rate, refusal rate, and incident logging must flow into Langfuse + an immutable audit store (object lock / WORM).

### 4.2 ISO/IEC 42001 (AI Management System)

Hook the platform into the AIMS controls:

- **A.6** — AI policies referenced in repo `README` and enforced via PR templates.
- **A.7.4** — Resources (compute, data) inventoried via the model registry + GPU labels.
- **A.8** — Impact assessments stored as `ai-impact/<model>.md` and reviewed quarterly.
- **A.9** — Lifecycle: every promotion (dev → staging → prod) requires a signed eval report.

### 4.3 NIST AI RMF crosswalk

Map controls 1:1 to **GOVERN / MAP / MEASURE / MANAGE** functions. Useful when serving US-headquartered customers in parallel with EU clients.

### 4.4 GDPR & data sovereignty

- **Local inference is the default.** No prompt or completion may leave EU jurisdiction unless an SCC + DPIA covers the flow.
- **Right to erasure.** Cache layers (semantic cache, KV cache offload) MUST be tenant-scoped and tombstoned on tenant deletion.
- **Logs.** Retention defined per tenant; default 30 days for prompts/completions, 13 months for metadata.
- **DPA template.** Always attach `dpa/<tenant>.md` to the tenant onboarding PR.

### 4.5 Sector-specific

- **Healthcare (DE).** BfArM medical device implications when output drives clinical decisions. MDR Class IIa+ requires a Notified Body. Anonymize per § 27 BDSG.
- **Defense.** BSI IT-Grundschutz baseline + air-gapped option (no telemetry egress; replace OTLP/HTTP with file-based exporters).
- **Finance.** BaFin MaRisk AT 9 (outsourcing) + DORA operational resilience. Maintain an exit plan from any non-EU vendor.

---

## 5. Supply-chain & runtime security

### 5.1 Model supply chain

- **Pin by digest.** Reference weights by SHA-256, never by tag (`@sha256:...`).
- **Sign and verify.** Push weights to a private OCI registry (Harbor / Artifactory) and sign with **Sigstore cosign**. Verify in-cluster with **Kyverno** policy `verifyImages` extended to `verifyImagesData` for model artifacts.
- **SBOM.** Generate a CycloneDX SBOM per image (`syft`) AND a **Model BOM** documenting base model, fine-tunes, datasets, and licenses. Store next to the image.
- **Vulnerability scan.** `trivy` on images; reject CRITICAL on the `prod` channel. Scan weights with **ModelScan** (Protect AI) for pickle / torch deserialization payloads — relevant for non-safetensors checkpoints.
- **License gate.** Block models with non-commercial / research-only licenses from prod via OPA policy.

### 5.2 Prompt-injection & data exfiltration defense

EchoLeak (CVE-2025-32711) and the McKinsey March-2026 incident both stemmed from indirect injection through retrieved content. Required controls:

- **Untrusted-content tagging.** Anything retrieved (RAG, web, email, attachments) is wrapped in `<untrusted>...</untrusted>` and the system prompt explicitly instructs the model to treat it as data.
- **Input/Output guardrails.** NeMo Guardrails or LlamaGuard 3 in-line at the gateway. Block known exfil patterns (markdown image with attacker-controlled URL, `[link](javascript:...)`, etc.).
- **Egress allowlist.** The model serving namespace must only reach: model registry, observability collectors, and (if applicable) the RAG store. Default-deny with NetworkPolicy / Cilium.
- **Tool-call mediation.** If the model has tools, every tool call passes through a policy engine (OPA) that revalidates the user's RBAC scope — never trust the model to enforce auth.
- **Output PII redaction.** Microsoft Presidio or Aim Security at the gateway response leg.

### 5.3 Secrets, identity, network

- **mTLS** between gateway, router, and engines via SPIFFE / cert-manager.
- **OIDC** at the gateway (Keycloak / Entra ID); JWT scopes mapped to LiteLLM virtual keys.
- **Secret store.** HashiCorp Vault or SOPS-encrypted in Git for IaC; **never** plain env in compose files.
- **Zero-trust.** Internal-only ingress for engine pods, even within the cluster.
- **Hardened base image.** `distroless` or `chainguard` for the LiteLLM container; vLLM stays on the upstream CUDA image but is run as non-root with `readOnlyRootFilesystem` where possible (vLLM tolerates it with `/tmp` and `/dev/shm` mounts).

### 5.4 Runtime hardening

- Drop all Linux capabilities except `IPC_LOCK` (needed for pinned memory).
- `seccomp: RuntimeDefault`.
- AppArmor profile restricting syscalls outside CUDA needs.
- For multi-tenant single-GPU sharing, prefer **MIG partitions** over time-slicing for isolation.

---

## 6. Inference engine layer

### 6.1 Engine selection (2026)

| Engine | Use it when | Avoid when |
|---|---|---|
| **vLLM 0.7+** | Default. Best general-purpose, broadest model coverage, PagedAttention + chunked prefill + speculative decoding mature. | You need extreme structured output throughput → SGLang. |
| **SGLang 0.4+** | High-throughput JSON / regex-constrained outputs, agent workloads with KV reuse across calls (RadixAttention). | Older models without SGLang support. |
| **TensorRT-LLM** | Maximum NVIDIA-specific perf on H100/H200/B200; fixed model catalog. | You need rapid model iteration — build cycle is heavy. |
| **TGI 3.x** | Hugging Face-centric shops. | New-model day-zero support — vLLM/SGLang are usually faster to add. |
| **Ollama / llama.cpp** | Edge / dev laptop / single user. | Production multi-tenant. |

### 6.2 Modern techniques to enable

- **Continuous batching** — on by default, do not disable.
- **Chunked prefill** (`--enable-chunked-prefill`) — required to keep TPOT stable when long prompts arrive.
- **Prefix caching** (`--enable-prefix-caching`) — huge win for system-prompt-heavy / agent / RAG workloads. Memory cost is real; size with `--num-gpu-blocks-override` or accept the default.
- **Speculative decoding** — pair a 1B–7B draft model with a 70B target. Typical 1.5–2.5× TPOT speedup at <1% accuracy delta. Validate per workload.
- **Multi-LoRA serving** (`--enable-lora --max-loras N`) — preferred over deploying N copies of the base model for fine-tuned variants.
- **Disaggregated prefill/decode** — separate pools optimized for compute-bound (prefill) vs memory-bound (decode) phases. Use vLLM disagg or NVIDIA Dynamo. Worth it above ~50 RPS sustained.
- **KV-cache offloading** with **LMCache** or **Mooncake** — spill warm KV to host RAM / NVMe / RDMA peers. Cuts cost dramatically for long-context shared-prefix workloads (legal, medical records).
- **Attention backends** — `FLASHINFER` on H100+; fall back to `XFORMERS` on Ampere; `FLASH_ATTN` on AMD via ROCm.

### 6.3 Quantization decision tree

```
Need max quality (clinical, legal)?
  └─ BF16 on H100/H200, FP16 on A100. No quant.

Throughput-bound, latency-tolerant?
  └─ FP8 (W8A8) on H100/H200/B200 — Llama 3.3 70B in 1×H100 80GB.

VRAM-bound on Ampere (no FP8)?
  └─ AWQ (W4A16) or GPTQ. AWQ usually wins on quality.

Edge / consumer GPU?
  └─ INT4 GGUF via llama.cpp; accept ~3–5% MMLU loss.

KV cache pressure (long context)?
  └─ FP8 KV cache (`--kv-cache-dtype fp8`) — recovers 2× context length with marginal quality cost.
```

Always run a **regression eval** (lm-eval + Promptfoo against a curated workload-specific suite) before promoting a quantized model. Quality regressions on long-tail prompts are common and not visible in MMLU.

### 6.4 vLLM configuration — production baseline

```yaml
# values.yaml (Helm) or env in compose
args:
  - --model=/models/llama-3.3-70b-instruct-fp8
  - --served-model-name=llama-3.3-70b
  - --tensor-parallel-size=4              # match physical GPUs/node behind NVLink
  - --pipeline-parallel-size=1            # only >1 across nodes
  - --gpu-memory-utilization=0.90         # 0.85 if co-located with embeddings
  - --max-model-len=32768                 # explicit; do not let vLLM auto-pick
  - --max-num-seqs=256
  - --enable-chunked-prefill
  - --enable-prefix-caching
  - --kv-cache-dtype=fp8
  - --dtype=auto                          # respect quant config
  - --quantization=fp8                    # explicit > inference
  - --disable-log-requests                # PII hygiene; log via OTEL with redaction
  - --otlp-traces-endpoint=http://otel-collector:4318/v1/traces
env:
  NCCL_IB_DISABLE: "1"                    # toggle to "0" if you have validated IB fabric
  NCCL_P2P_DISABLE: "0"
  NCCL_DEBUG: WARN                        # INFO only when triaging
  VLLM_USE_V1: "1"                        # V1 engine; 2026 default
  VLLM_LOGGING_LEVEL: INFO
  CUDA_DEVICE_ORDER: PCI_BUS_ID
  HF_HUB_OFFLINE: "1"                     # weights pulled from internal registry only
  TRANSFORMERS_OFFLINE: "1"
```

### 6.5 Hardware notes (2026)

| GPU | Memory | Best for | Watch out for |
|---|---|---|---|
| **H200 SXM** | 141 GB HBM3e | 70B FP8 single-GPU, long context | Power: 700W per GPU — plan PDUs. |
| **B200 / GB200 NVL72** | 192 GB / 13.5 TB pooled | 405B+ models, MoE, frontier inference | NVLink 5 fabric — engine support stabilizing in 2026. |
| **H100 SXM** | 80 GB | Workhorse for 70B FP8, 32B BF16 | Most field-tested; FP8 fully supported. |
| **L40S** | 48 GB | Mid-size models, embeddings, vision | No NVLink; tensor-parallel scales poorly across them. |
| **A100 80GB** | 80 GB | Legacy; FP16/BF16 only, no FP8 | Avoid for new builds unless free. |
| **MI300X** | 192 GB HBM3 | Memory-heavy workloads, second-source strategy | ROCm vLLM lags 1–2 minor versions. Validate. |

NCCL knobs that resolve the majority of multi-GPU hangs: `NCCL_IB_DISABLE`, `NCCL_P2P_DISABLE`, `NCCL_SHM_DISABLE`, `NCCL_NET_GDR_LEVEL`. Always set `NCCL_DEBUG=INFO` when triaging — never leave it on in prod (huge log volume).

---

## 7. Gateway / Proxy layer (LiteLLM)

### 7.1 Reference config

```yaml
model_list:
  - model_name: llama-3.3-70b
    litellm_params:
      model: openai/llama-3.3-70b
      api_base: http://vllm-llama33-70b.inference.svc:8000/v1
      api_key: os.environ/INTERNAL_LLM_KEY
      rpm: 1200
      tpm: 600000
    model_info:
      mode: chat
      supports_function_calling: true
  - model_name: qwen2.5-coder-32b
    litellm_params:
      model: openai/qwen2.5-coder-32b
      api_base: http://vllm-qwen-coder.inference.svc:8000/v1

router_settings:
  routing_strategy: latency-based-routing
  fallbacks:
    - llama-3.3-70b: [llama-3.1-70b, llama-3.1-8b]   # graceful degradation
  context_window_fallbacks:
    - llama-3.3-70b: [qwen2.5-128k]
  retry_policy:
    max_retries: 2
    retry_after: 1
  timeout: 60
  redis_host: os.environ/REDIS_HOST
  cache_responses: true                                # semantic cache
  cache:
    type: redis-semantic
    similarity_threshold: 0.95
    ttl: 600

general_settings:
  master_key: os.environ/LITELLM_MASTER_KEY
  database_url: os.environ/DATABASE_URL                # PostgreSQL HA
  enforce_user_param: true                              # mandate `user` field for auditability
  max_request_size_mb: 8
  alerting: ["slack"]
  alert_types: ["budget_alerts","outage_alerts","db_exceptions"]

litellm_settings:
  set_verbose: false
  json_logs: true                                       # required for Loki
  callbacks: ["otel","langfuse"]
  redact_user_api_key_info: true
  success_callback: ["langfuse"]
  failure_callback: ["langfuse","sentry"]
  drop_params: true
  default_team_settings:
    - team_id: default
      max_budget: 100.0
      budget_duration: 30d
```

### 7.2 Operating rules

- **Always HA.** Minimum 3 LiteLLM replicas behind a `Service` with `topologySpreadConstraints` across zones/racks.
- **Postgres** for keys/budgets — use a managed HA PG (Patroni / CloudNativePG). LiteLLM running without a DB is for dev only.
- **Redis** for the semantic cache — separate instance from session/state caches. Cluster mode if QPS > 5k.
- **Virtual keys** map 1:1 to (tenant, application, environment). Never share keys across apps.
- **Budgets** are enforced server-side; rotate on calendar boundaries and emit `budget_alerts` to the tenant's channel.
- **`LITELLM_LOG=INFO`** in prod. `DEBUG` adds 10–25% latency from synchronous I/O.
- **Failover order** is explicit (smaller / cheaper / older). Add a final hop to a hosted EU-region API only if compliance-cleared.

---

## 8. Containerization & orchestration

### 8.1 Docker Compose (single-node, lab/edge)

```yaml
services:
  vllm-llama33:
    image: ghcr.io/<org>/vllm:0.7.3@sha256:<digest>
    runtime: nvidia
    ipc: host
    shm_size: "16gb"
    user: "1000:1000"
    read_only: true
    tmpfs: [ "/tmp", "/dev/shm" ]
    cap_drop: [ "ALL" ]
    cap_add: [ "IPC_LOCK" ]
    security_opt:
      - "no-new-privileges:true"
      - "seccomp=default"
    environment:
      VLLM_USE_V1: "1"
      NCCL_IB_DISABLE: "1"
    deploy:
      resources:
        reservations:
          devices: [ { driver: nvidia, count: 4, capabilities: [gpu] } ]
    volumes:
      - /srv/models:/models:ro
    healthcheck:
      test: ["CMD", "curl", "-fsS", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 900s          # 70B FP8 cold load: 5–8 min on NVMe
    logging:
      driver: json-file
      options: { max-size: "50m", max-file: "5" }
    labels:
      autoheal: "true"
      compliance.tag: "eu-ai-act-high-risk"
```

Compose is fine for single-node, single-tenant work and edge deployments. **Do not** scale Compose to multi-node — it is not built for it.

### 8.2 Kubernetes (default for ≥ 2 nodes / multi-tenant)

- **Helm chart** per engine (`vllm`, `sglang`, `litellm`, `lmcache`, `dcgm-exporter`).
- **GitOps** via ArgoCD or Flux. PRs trigger eval pipelines; merge promotes via Kustomize overlays (`base / overlays/dev|stage|prod`).
- **NVIDIA GPU Operator** for driver, fabric manager, MIG, and DCGM lifecycle.
- **KAI-Scheduler / Kueue** for fair queueing across teams; **Volcano** if doing gang-scheduled distributed inference.
- **Karpenter / Cluster Autoscaler** with GPU-aware node pools; tag nodes with `accelerator=h100-sxm-80gb` and use `nodeAffinity`, not just tolerations.
- **PodDisruptionBudgets** that respect GPU node drain windows (DCGM XID-aware draining via the GPU operator).
- **Probes.** Readiness probe on `/health` *only after* `start_period` equivalent — implement as `startupProbe` (`failureThreshold * periodSeconds ≥ cold-load time`).
- **Persistence.** Model weights on a fast read-only volume — local NVMe via Local PV (preferred) or a high-throughput shared FS (Lustre/Weka). Avoid pulling weights at pod start unless the registry is on the same fabric.

### 8.3 GitOps & policy

- **Kyverno** policies enforce: signed images + signed weights, no `:latest`, `runAsNonRoot`, NetworkPolicy presence, required labels (`compliance`, `tenant`, `model-version`).
- **OPA Gatekeeper** for cross-cutting constraints and EU-AI-Act labels.
- **Crossplane / Terraform** for the cluster, registry, and Postgres.

---

## 9. Observability (OpenTelemetry-first)

### 9.1 Stack

- **OpenTelemetry Collector** as the only telemetry pipeline. Engines emit OTLP; collector fans out to backends.
- **Metrics → Prometheus / Mimir.** Long-term store for SLO compliance.
- **Logs → Loki.** JSON, structured, with redaction processor in the collector (Presidio sidecar pattern).
- **Traces → Tempo.** vLLM, LiteLLM, and the gateway all participate in one trace ID.
- **LLM-specific → Langfuse (self-hosted, EU region).** Prompt/completion-level traces, evals, datasets. Sample rate per tenant; full capture for high-risk models.
- **GPU → DCGM Exporter** scraped by Prometheus.
- **Node → Node Exporter, eBPF (Pixie / Parca) for deep perf**.

### 9.2 Mandatory metrics

**Engine (vLLM exposes most natively at `/metrics`):**

- `vllm:time_to_first_token_seconds` — TTFT histogram.
- `vllm:time_per_output_token_seconds` — TPOT histogram.
- `vllm:e2e_request_latency_seconds`.
- `vllm:gpu_cache_usage_perc`, `vllm:cpu_cache_usage_perc` — KV pressure.
- `vllm:num_requests_running / waiting / swapped`.
- `vllm:prompt_tokens_total`, `vllm:generation_tokens_total`.
- `vllm:request_success_total`, `vllm:request_error_total{reason}`.

**Gateway (LiteLLM):** request count, latency, virtual-key consumption, budget remaining, fallback hits, semantic-cache hit ratio.

**GPU (DCGM):** `DCGM_FI_DEV_GPU_UTIL`, `DCGM_FI_DEV_FB_USED`, `DCGM_FI_DEV_POWER_USAGE`, `DCGM_FI_DEV_GPU_TEMP`, `DCGM_FI_DEV_XID_ERRORS` (alert on any non-zero), `DCGM_FI_PROF_PIPE_TENSOR_ACTIVE` (real tensor-core utilization, not just `GPU_UTIL`).

### 9.3 Golden dashboards

1. **Tenant SLO** — TTFT p50/p95/p99, TPOT p95, error rate, budget burn.
2. **Engine health** — KV cache %, queue depth, batched-tokens/sec, prefix-cache hit rate.
3. **GPU fleet** — utilization, VRAM, power, temp, XID, throttle reasons.
4. **FinOps** — €/1k tokens in vs out, €/tenant/day, idle GPU-hours.

### 9.4 SLO catalog (defaults; tighten per tenant)

| SLO | Target |
|---|---|
| API availability (gateway 2xx + 4xx that aren't 429) | 99.9% / 30d |
| TTFT p95 (≤ 1k input tokens) | ≤ 500 ms (chat); ≤ 2 s (RAG) |
| TPOT p95 | ≤ 50 ms |
| End-to-end p99 (≤ 1k in / ≤ 256 out) | ≤ 8 s |
| Semantic-cache hit ratio | ≥ 25% (RAG / agent workloads) |
| GPU XID error count | 0 in any 24h window |

Run **error-budget burn-rate alerts** (multi-window, multi-burn-rate per Google SRE Workbook) — not raw threshold alerts.

---

## 10. FinOps for inference

### 10.1 Cost model

```
cost_per_request ≈ (input_tokens × $/in_token) + (output_tokens × $/out_token)
$/in_token, $/out_token ≈ (GPU_hourly_cost / engine_throughput_tps) × overhead_factor
```

Track at **request granularity** in Langfuse and aggregate to tenant/team in Mimir. Forecast monthly with Prophet or a simple ARIMA on rolling 28d.

### 10.2 Optimization levers (in order of ROI)

1. **Semantic cache** — easy 20–60% cost reduction on agent / RAG / repetitive workloads. Default-on.
2. **Prefix caching** — cuts prefill cost for shared system prompts.
3. **Right-size the model.** A 32B Qwen Coder beats 70B general on coding at 30% of the cost. Route by task class at the gateway.
4. **Quantize.** FP8 on H100/H200 typically halves cost vs BF16 with <1% quality delta on most tasks.
5. **Speculative decoding** — 1.5–2.5× throughput when configured carefully.
6. **MIG partitioning** for embedding / small-model workloads on shared H100/H200.
7. **Schedule batch jobs off-peak** when on-prem capacity is shared with batch training.
8. **Spot / preemptible** for stateless gateway pods only — NEVER for engines holding KV.

### 10.3 Budgeting

- Per-tenant monthly budget in LiteLLM with `budget_duration: 30d`.
- Hard-stop at 100%, soft-warn at 80%, daily Slack digest of top consumers.
- Chargeback report generated monthly (`xlsx` skill output) — token volume, cost, model mix, cache hit rate.

---

## 11. Reliability & SRE

### 11.1 Failure-mode matrix (deploy-time review)

| Failure | Detection | Mitigation |
|---|---|---|
| GPU XID fault | DCGM `XID_ERRORS` | GPU operator drains node; pod reschedules. |
| Engine OOM | `vllm:request_error_total{reason="out_of_memory"}` | Reduce `max-num-seqs` / `max-model-len`; rollback. |
| NCCL all-reduce hang | TTFT spike + `NCCL` log timeout | Restart pod (autoheal); check IB fabric. |
| Model file corruption | Cosign verification fails | Pod fails to start; alert; pull from secondary registry. |
| Postgres HA failover | LiteLLM 5xx | Connection retry + backoff; circuit breaker on routes that need DB. |
| Region outage | Multi-region probe miss | DNS failover (Route53 / RFC2136) to standby region. |

### 11.2 Required patterns

- **Circuit breaker** at the gateway (Envoy / LiteLLM) — open after N consecutive 5xx, half-open probe.
- **Fallback chain** at the router (already shown in §7.1).
- **Bulkhead** — separate engine pools per tenant tier to prevent one team starving another.
- **Canary deploys** — 1% / 10% / 50% / 100% with auto-rollback on SLO burn. Argo Rollouts with `analysisTemplate` consuming Mimir queries.
- **Shadow mode** — duplicate traffic to a candidate model, compare via Langfuse evals, never return its output.
- **Chaos engineering** — quarterly drills: kill an engine pod, drain a GPU node, partition Redis, fail Postgres primary. Game-day playbook lives in the runbook.

### 11.3 DR / BCP

- **RPO** for config / keys / Langfuse: ≤ 15 min (PITR on Postgres + object versioning on Langfuse blob store).
- **RTO** for inference plane: ≤ 60 min to a warm-standby region; ≤ 15 min if both regions are active-active behind GeoDNS.
- **Model store** replicated to a secondary registry in a different EU region.
- **Runbooks** in Git; tested at least every 6 months with a real failover.

---

## 12. MLOps / model lifecycle

- **Model registry.** MLflow (self-hosted, EU) or W&B with on-prem connector. Every model version has: weights digest, eval report, model card, BOM, license, deployer of record.
- **Eval harness.** `lm-evaluation-harness` for capability benches + **Promptfoo** for workload-specific regressions + a **red-team suite** (LlamaGuard, Aegis, internal). Run on every promotion PR.
- **Drift detection.** Weekly Langfuse dataset replay on a frozen prompt set; alert if score drops > 2σ.
- **A/B testing.** Argo Rollouts experiment templates with statistical significance gating (e.g., chi-squared on user thumbs up/down; latency Mann-Whitney).
- **Retire / deprecate** policy. EOL 60 days after a successor is GA; force-migrate via gateway alias.

---

## 13. Multi-tenancy

- **Logical isolation per tenant** at every layer: virtual key, namespace, semantic-cache key prefix, Langfuse project, audit-log stream.
- **Resource quotas** on namespaces; GPU fractions via MIG for small tenants.
- **PII boundary.** Tenant data never crosses tenant lines, including for metric aggregation (use cardinality-safe labels).
- **Per-tenant guardrails** — some sectors require stricter PII policies (healthcare > general).
- **Tenant offboarding playbook** — purge keys, semantic cache, KV offload tier, Langfuse project, and audit-archive the data with retention metadata.

---

## 14. Implementation patterns

### 14.1 Reference model selection (on-prem, EU 2026)

| Need | Model | Notes |
|---|---|---|
| General reasoning, multilingual | **Llama 3.3 70B Instruct (FP8)** | 1×H100/H200; long-context to 128k. |
| Code generation | **Qwen 2.5 Coder 32B (BF16/FP8)** | Beats 70B general on code; cheaper. |
| Multimodal vision | **Gemma 3 / Qwen 2.5-VL 32B** | Validate VLM eval suite before clinical use. |
| Tool-use / agents | **Llama 3.3 70B + structured outputs (SGLang)** | RadixAttention shines here. |
| Embeddings | **Qwen3-Embedding 0.6B** or **bge-m3** | Run on L40S/MIG slice; never on the LLM GPU. |
| Reranker | **bge-reranker-v2-m3** | Latency-sensitive — TensorRT recommended. |
| Guardrails | **LlamaGuard 3 8B / NeMo Guardrails** | In-line, low-latency. |

### 14.2 Capacity sizing rule of thumb

```
required_GPU_count =
  ceil(
    peak_concurrent_requests
    × avg_(input_tokens + 0.5 × output_tokens)        # tokens-in-flight estimate
    / engine_max_num_batched_tokens
  )
  × tensor_parallel_size
  × redundancy_factor (≥ 2 for prod)
```

Sanity-check with a `vllm bench` or `genai-perf` (NVIDIA) load test against the SLO targets BEFORE committing capacity.

### 14.3 Cold-start playbook

1. Pre-pull weights to node-local NVMe via a `DaemonSet` job.
2. Use `startupProbe` (not just `readinessProbe`) sized for the model.
3. Warm the prefix cache with the canonical system prompt at startup.
4. Mark pod `Ready` only after a synthetic request returns within SLO.

---

## 15. Troubleshooting protocol (extended)

| Symptom | First-3-checks | Resolution |
|---|---|---|
| **CUDA OOM at startup** | (1) `nvidia-smi` — zombie procs? `fuser -v /dev/nvidia*`. (2) `gpu-memory-utilization`. (3) `max-model-len` × `max-num-seqs` × dtype size. | Lower utilization or `max-model-len`; kill orphans; verify no other container shares the GPU. |
| **CUDA OOM mid-traffic** | (1) `vllm:gpu_cache_usage_perc` > 95%? (2) Long input outliers? (3) Prefix-cache fragmentation? | Cap `max_model_len` per request at the gateway; enable chunked prefill; reduce `max-num-seqs`. |
| **Hanging inference (multi-GPU)** | (1) `NCCL_DEBUG=INFO` logs. (2) `ipc: host` / `shm_size`. (3) IB fabric / `nccl-tests`. | Set `NCCL_IB_DISABLE=1` if no validated IB; ensure shm; confirm topology with `nvidia-smi topo -m`. |
| **Slow TPOT, fast TTFT** | (1) Tensor-core util via DCGM `PROF_PIPE_TENSOR_ACTIVE`. (2) Quant config sane? (3) Speculative draft model alignment. | Validate dtype matches GPU capability; tune draft model; check thermal throttle (`DCGM_FI_DEV_THERMAL_VIOLATION`). |
| **Slow TTFT, fast TPOT** | (1) Long input + no chunked prefill. (2) Cold prefix cache. (3) Queue depth. | Enable chunked prefill; raise `max-num-batched-tokens`; scale prefill replicas in disagg mode. |
| **Proxy 5xx bursts** | (1) Postgres connectivity. (2) Redis health. (3) Engine `request_error_total`. | Check DB pool sizing; failover Redis; re-route via fallback chain. |
| **Quality regression after upgrade** | (1) Eval harness diff. (2) Quant config changed? (3) Tokenizer hash. | Rollback via GitOps revert; pin tokenizer alongside weights. |
| **Audit gap (compliance failure)** | (1) `enforce_user_param`. (2) OTEL sampling 100% on high-risk? (3) WORM bucket retention. | Enable mandatory `user`; raise sampling; verify object-lock policy. |

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

- [ ] Risk classification recorded; EU AI Act obligations mapped.
- [ ] Model card, BOM, eval report, and DPIA signed off.
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

- **EU AI Act** (Regulation (EU) 2024/1689) — Articles 9–15 (high-risk), Article 26 (deployers), Article 53–55 (GPAI).
- **ISO/IEC 42001:2023** — AI Management System.
- **NIST AI RMF 1.0** + Generative AI Profile (NIST-AI-600-1).
- **OWASP Top 10 for LLM Applications (2025)** — LLM01 prompt injection, LLM02 sensitive info disclosure, LLM06 excessive agency.
- **OWASP API Security Top 10 (2023)** — applies to the gateway layer.
- **Google SRE Workbook** — multi-window multi-burn-rate alerting.
- **NVIDIA DCGM, GPU Operator, NeMo Guardrails** docs.
- **vLLM** (`docs.vllm.ai`), **SGLang** (`docs.sglang.ai`), **LiteLLM** (`docs.litellm.ai`), **Langfuse** (`langfuse.com/docs`), **LMCache** (`lmcache.ai`).
- **Sigstore cosign**, **Kyverno**, **CycloneDX**.

---

## 19. Companion artifacts (suggested next steps)

When this skill is invoked end-to-end, generate these alongside the architecture:

1. `helm/` — vLLM + LiteLLM + LMCache + DCGM Helm values.
2. `compose/` — single-node lab variant.
3. `policies/` — Kyverno + OPA bundles.
4. `dashboards/` — Grafana JSON for the four golden dashboards.
5. `runbooks/` — incident playbooks (OOM, NCCL hang, regional failover).
6. `model-cards/<model>.md` — EU AI Act-compliant template.
7. `eval/` — Promptfoo + lm-eval-harness configs.

Use a slide-deck-generation skill when the deliverable includes a stakeholder-facing architecture review.
