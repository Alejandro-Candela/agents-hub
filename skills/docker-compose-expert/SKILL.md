---
name: docker-compose-expert
description: Expert in Docker Compose v2 including multi-service orchestration, GPU passthrough (NVIDIA), networking, health checks, profiles, volumes, and production-ready configurations. Use when writing or debugging docker-compose.yml, container networking, GPU support, or service dependencies.
---

# Docker Compose Expert

## When to use this skill
- Writing or modifying docker-compose.yml files
- Configuring GPU passthrough for NVIDIA containers (vLLM, Ollama, NIM)
- Setting up service networking and dependencies
- Debugging container health checks or startup ordering
- Using Compose profiles for optional services
- Optimizing build/pull performance

## When NOT to use
- Kubernetes/Helm deployments
- Terraform/Bicep infrastructure (use azure-verified-modules or terraform skill)

## Instructions

### 1. Fetch up-to-date documentation
Use context7 MCP:
- `resolve-library-id` with libraryName: "docker compose"
- `query-docs` for the specific topic

### 2. Core patterns from Golden Stacks

#### GPU Passthrough (NVIDIA)
```yaml
services:
  vllm:
    image: vllm/vllm-openai:latest
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all  # or specific: count: 1
              capabilities: [gpu]
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
    volumes:
      - model-cache:/root/.cache/huggingface
```

#### Health Checks with Dependency Ordering
```yaml
services:
  postgres:
    image: postgres:16-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 5s
      timeout: 5s
      retries: 5

  api:
    build: .
    depends_on:
      postgres:
        condition: service_healthy
      qdrant:
        condition: service_healthy
```

#### Profiles for Optional Services
```yaml
services:
  grafana:
    image: grafana/grafana:latest
    profiles: ["observability"]

  langfuse:
    image: langfuse/langfuse:latest
    profiles: ["observability"]

# Start with: docker compose --profile observability up
```

#### Internal Network (Air-gapped / Sovereign)
```yaml
networks:
  sovereign-net:
    driver: bridge
    internal: true  # No external access — fully isolated

services:
  api:
    networks:
      - sovereign-net
  vllm:
    networks:
      - sovereign-net
```

#### Named Volumes for Persistence
```yaml
volumes:
  postgres-data:
  qdrant-data:
  model-cache:     # HuggingFace model cache — survives rebuilds
  es-data:         # Elasticsearch data
  grafana-data:
```

#### Full Stack Pattern (typical Golden Stack)
```yaml
services:
  api:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "${API_PORT:-8080}:8080"
    env_file: .env
    depends_on:
      postgres:
        condition: service_healthy
      qdrant:
        condition: service_started
    volumes:
      - ./src:/app/src:ro  # Hot-reload in dev

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./infra/sql:/docker-entrypoint-initdb.d:ro
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 5s
      timeout: 5s
      retries: 5
```

### 3. Best practices
- Always use Compose v2 syntax (no `version:` key needed)
- Use `env_file: .env` instead of inline `environment:` for secrets
- Always add health checks to databases and critical services
- Use `depends_on` with `condition: service_healthy` (not just `service_started`)
- Use named volumes for all persistent data
- Use `:ro` mount flag for read-only bind mounts
- Variable substitution: `${VAR:-default}` for optional env vars
- Use `profiles` for optional services (observability, debugging tools)
- For GPU: always use `deploy.resources.reservations.devices` (not deprecated `runtime: nvidia`)
- Pin image tags in production (not `:latest`)

## Project Conventions

Naming: service names lowercase/hyphenated; volumes `{project}-{service}-data`; networks `{project}-{tier}` (e.g. `myapp-backend`).

Dockerfile: multi-stage (`builder` + slim `runtime`), non-root `appuser`, `.dockerignore` excludes `.git`, `node_modules`, `.venv`, `__pycache__`, `.env`.

Environment: `.env` for local (never commit), `.env.example` with placeholders (commit this), secrets via Docker secrets / vault in production.

Never expose database ports to host in production compose files.
