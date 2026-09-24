---
name: ollama-expert
description: Expert in Ollama local LLM inference including model management, Modelfile customization, embedding endpoints, API usage, and Docker deployment. Use when running local models with Ollama, pulling models, creating custom Modelfiles, or integrating Ollama with n8n or LangChain.
disable-model-invocation: true
---

# Ollama Expert

## When to use this skill
- Pulling and managing local models
- Creating custom Modelfiles (system prompts, parameters)
- Using the Ollama REST API for chat/embeddings
- Docker deployment with GPU support
- Integrating Ollama with n8n AI nodes or LangChain
- Choosing models by VRAM/quality tradeoff

## When NOT to use
- vLLM inference server (use vllm-expert)
- Cloud-hosted models (Azure, OpenAI)

## Instructions

### 1. Fetch up-to-date documentation
Use context7 MCP:
- `resolve-library-id` with libraryName: "ollama"
- `query-docs` for the specific topic

### 2. Core patterns from Edge & Low-Cost Stack

#### Docker Compose
```yaml
ollama:
  image: ollama/ollama:latest
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: 1
            capabilities: [gpu]
  ports:
    - "11434:11434"
  volumes:
    - ollama-data:/root/.ollama
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:11434/api/tags"]
    interval: 10s
    timeout: 5s
    retries: 3
```

#### Model Pull (via Makefile)
```makefile
pull-model:
	docker compose exec ollama ollama pull $(OLLAMA_MODEL)

OLLAMA_MODEL ?= llama3.1:8b
```

#### Model Selection Guide
| Model | VRAM | Quality | Speed | Best For |
|---|---|---|---|---|
| `llama3.1:8b` | ~6GB | Good | Fast | General chat, RAG |
| `llama3.1:8b-q4_K_M` | ~4.7GB | Slightly lower | Very fast | Low-resource |
| `mistral-small:latest` | ~14GB | Very good | Medium | Complex reasoning |
| `gemma2:9b` | ~6GB | Good | Fast | Multilingual |
| `nomic-embed-text` | ~300MB | Excellent | Very fast | Embeddings only |
| `mxbai-embed-large` | ~700MB | Excellent | Fast | Embeddings (1024d) |

#### Custom Modelfile
```dockerfile
FROM llama3.1:8b

SYSTEM """Eres un asistente empresarial. Responde siempre en español.
Sé conciso y profesional. Si no sabes algo, dilo claramente."""

PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER num_ctx 4096
PARAMETER stop "<|eot_id|>"
```

```bash
ollama create mi-asistente -f Modelfile
```

#### REST API Usage
```python
import httpx

# Chat completion
response = httpx.post("http://ollama:11434/api/chat", json={
    "model": "llama3.1:8b",
    "messages": [{"role": "user", "content": "Hola"}],
    "stream": False,
})

# Embeddings
response = httpx.post("http://ollama:11434/api/embed", json={
    "model": "nomic-embed-text",
    "input": ["Texto para embeddings"],
})
embeddings = response.json()["embeddings"]
```

#### n8n Integration
In n8n AI Agent node configuration:
- **Chat Model**: Ollama Chat Model node → `http://ollama:11434`
- **Embeddings**: Ollama Embeddings node → model: `nomic-embed-text`
- **Memory**: Chat Memory Manager → Window Buffer (last N messages)

### 3. Best practices
- Always use quantized models (`q4_K_M`) on machines with <16GB VRAM
- Use `nomic-embed-text` for embeddings (fastest, good quality, 768d)
- Set `num_ctx` explicitly — default is often 2048 which is too low for RAG
- Mount `/root/.ollama` as named volume to persist downloaded models
- For n8n: connect via Docker network name (`ollama:11434`), not localhost
- Pre-pull models in Docker entrypoint or Makefile target to avoid cold start
- Use `/api/embed` (not `/api/embeddings`) — this is the correct endpoint
- Monitor VRAM with `nvidia-smi` — Ollama doesn't always report OOM clearly
