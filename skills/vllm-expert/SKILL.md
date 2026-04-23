---
name: vllm-expert
description: Expert in vLLM inference server including model serving, tensor parallelism, quantization (AWQ/GPTQ), LoRA adapters, OpenAI-compatible API, and GPU optimization. Use when deploying local LLM inference, configuring vLLM, optimizing GPU memory, or troubleshooting model loading.
---

# vLLM Expert

## When to use this skill
- Deploying vLLM as inference server (Docker or bare metal)
- Configuring tensor parallelism for multi-GPU setups
- Choosing quantization strategy (AWQ, GPTQ, FP8)
- Serving LoRA adapters dynamically
- Troubleshooting OOM errors or slow inference
- Using vLLM's OpenAI-compatible API

## When NOT to use
- Cloud-hosted inference (Azure AI Foundry, OpenAI API)
- Ollama (use ollama-expert)

## Instructions

### 1. Fetch up-to-date documentation
Use context7 MCP:
- `resolve-library-id` with libraryName: "vllm"
- `query-docs` for the specific topic

### 2. Core patterns from Golden Stacks

#### Docker Compose Deployment
```yaml
vllm:
  image: vllm/vllm-openai:latest
  command: >
    --model ${VLLM_MODEL:-meta-llama/Llama-3.3-70B-Instruct}
    --tensor-parallel-size ${VLLM_TP:-1}
    --max-model-len ${VLLM_MAX_MODEL_LEN:-4096}
    --gpu-memory-utilization 0.90
    --dtype auto
    --enforce-eager
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: all
            capabilities: [gpu]
  ports:
    - "8000:8000"
  volumes:
    - model-cache:/root/.cache/huggingface
  environment:
    - HUGGING_FACE_HUB_TOKEN=${HF_TOKEN}
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
    interval: 30s
    timeout: 10s
    retries: 3
    start_period: 120s  # Models take time to load
```

#### OpenAI-Compatible API Usage
```python
from openai import AsyncOpenAI

client = AsyncOpenAI(
    base_url="http://vllm:8000/v1",
    api_key="not-needed",  # vLLM doesn't require auth by default
)

response = await client.chat.completions.create(
    model="meta-llama/Llama-3.3-70B-Instruct",
    messages=[{"role": "user", "content": "Hello"}],
    temperature=0.7,
    max_tokens=1024,
    stream=True,
)
```

#### Multi-GPU Tensor Parallelism
```bash
# 2x A100 80GB → can serve 70B model
--tensor-parallel-size 2

# 4x A10G 24GB → can serve 70B quantized
--tensor-parallel-size 4 --quantization awq
```

#### Quantization Options
| Method | VRAM Savings | Quality | Flag |
|---|---|---|---|
| AWQ | ~4x | Excellent | `--quantization awq` |
| GPTQ | ~4x | Excellent | `--quantization gptq` |
| FP8 | ~2x | Near-lossless | `--dtype float8_e4m3fn` |
| None | Baseline | Best | (default) |

### 3. Best practices
- Always set `--gpu-memory-utilization 0.90` (leave headroom for KV cache)
- Use `--enforce-eager` to disable CUDA graphs if hitting OOM during startup
- Set `start_period` in healthcheck to 120s+ (large models take time)
- For production: pin model revision with `--revision <commit-hash>`
- Use `--max-model-len` to cap context window and reduce VRAM
- Mount HuggingFace cache as volume to avoid re-downloading on restart
- For LoRA: `--enable-lora --max-loras 4 --max-lora-rank 64`
- Monitor with `/metrics` endpoint (Prometheus format)
