---
name: opentelemetry-expert
description: Expert in OpenTelemetry instrumentation, OTel Collector configuration, exporters, Grafana/Prometheus/Tempo integration, and distributed tracing. Use when working with OTel, traces, metrics, spans, collectors, or observability pipelines. Use PROACTIVELY when code touches logging, tracing, or monitoring.
disable-model-invocation: true
---

# OpenTelemetry Expert

## When to use this skill
- Configuring OTel Collector pipelines (receivers, processors, exporters)
- Instrumenting Python/FastAPI apps with opentelemetry-sdk
- Setting up Grafana + Prometheus + Tempo stack
- Debugging distributed traces or missing spans
- Adding custom metrics or span attributes
- Configuring sampling strategies

## When NOT to use
- Pure application logic unrelated to observability
- Cloud-specific monitoring (use azure-ai-foundry or devops-troubleshooter instead)

## Instructions

### 1. Fetch up-to-date documentation
Use the context7 MCP to get current docs:
- `resolve-library-id` with libraryName: "opentelemetry-python"
- `query-docs` with the resolved ID for the specific topic

### 2. Core architecture knowledge

#### OTel Collector Config Pattern (used in Golden Stacks)
```yaml
# otel-collector-config.yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 5s
    send_batch_size: 1024
  memory_limiter:
    check_interval: 1s
    limit_mib: 512
  resource:
    attributes:
      - key: service.namespace
        value: "golden-stack"
        action: upsert

exporters:
  prometheus:
    endpoint: "0.0.0.0:8889"
  otlp/tempo:
    endpoint: tempo:4317
    tls:
      insecure: true
  logging:
    loglevel: warn

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [otlp/tempo, logging]
    metrics:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [prometheus]
```

#### Python SDK Instrumentation (FastAPI)
```python
from opentelemetry import trace, metrics
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.sdk.resources import Resource

resource = Resource.create({
    "service.name": "my-agent-api",
    "service.version": "1.0.0",
    "deployment.environment": "production",
})

provider = TracerProvider(resource=resource)
provider.add_span_processor(
    BatchSpanProcessor(OTLPSpanExporter(endpoint="http://otel-collector:4317"))
)
trace.set_tracer_provider(provider)

# Auto-instrument FastAPI
FastAPIInstrumentor.instrument_app(app)
```

#### Docker Compose Service
```yaml
otel-collector:
  image: otel/opentelemetry-collector-contrib:latest
  command: ["--config=/etc/otel/config.yaml"]
  volumes:
    - ./infra/otel/config.yaml:/etc/otel/config.yaml:ro
  ports:
    - "4317:4317"   # OTLP gRPC
    - "4318:4318"   # OTLP HTTP
    - "8889:8889"   # Prometheus metrics
  depends_on:
    - tempo
    - prometheus
```

### 3. Best practices
- Always set `service.name` and `service.version` in Resource attributes
- Use `BatchSpanProcessor` (never `SimpleSpanProcessor`) in production
- Set `memory_limiter` processor in collector to prevent OOM
- Sample rate: 1.0 in dev, 0.1-0.5 in production depending on traffic
- Add trace_id to structured logs for correlation: `logging.info("msg", extra={"trace_id": span.get_span_context().trace_id})`
- Use `otel/opentelemetry-collector-contrib` image (not base) for all exporters
