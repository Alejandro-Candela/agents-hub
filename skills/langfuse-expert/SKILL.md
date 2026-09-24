---
name: langfuse-expert
description: Expert in Langfuse observability platform for LLM tracing, cost tracking, prompt management, scoring, datasets, and self-hosted deployment. Use when setting up Langfuse tracing, analyzing LLM costs, managing prompts, or configuring self-hosted Langfuse with Docker.
disable-model-invocation: true
---

# Langfuse Expert

## When to use this skill
- Setting up Langfuse tracing for LLM applications
- Tracking per-request costs and token usage
- Managing prompt versions and A/B testing
- Creating evaluation datasets and scoring
- Self-hosted Langfuse deployment with Docker
- Integrating with LangChain, LangGraph, or OpenAI SDK

## When NOT to use
- OpenTelemetry/Grafana observability (use opentelemetry-expert)
- Arize Phoenix (different tool, similar purpose)
- Azure Application Insights (use azure-ai-foundry)

## Instructions

### 1. Fetch up-to-date documentation
Use context7 MCP:
- `resolve-library-id` with libraryName: "langfuse"
- `query-docs` for the specific topic

### 2. Core patterns from Edge & Low-Cost Stack

#### Docker Compose (Self-hosted)
```yaml
langfuse:
  image: langfuse/langfuse:latest
  ports:
    - "3001:3000"
  environment:
    - DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/langfuse
    - NEXTAUTH_URL=http://localhost:3001
    - NEXTAUTH_SECRET=${LANGFUSE_NEXTAUTH_SECRET}
    - SALT=${LANGFUSE_SALT}
    - LANGFUSE_ENABLE_EXPERIMENTAL_FEATURES=true
  depends_on:
    postgres:
      condition: service_healthy
```

#### Python SDK Integration
```python
from langfuse import Langfuse
from langfuse.decorators import observe, langfuse_context

langfuse = Langfuse(
    public_key=os.environ.get("LANGFUSE_PUBLIC_KEY"),
    secret_key=os.environ.get("LANGFUSE_SECRET_KEY"),
    host=os.environ.get("LANGFUSE_HOST", "http://localhost:3001"),
)

@observe()
async def process_query(query: str, tenant_id: str) -> str:
    langfuse_context.update_current_trace(
        user_id=tenant_id,
        metadata={"source": "api"},
    )

    # This automatically traces the LLM call
    response = await llm.ainvoke(query)

    langfuse_context.update_current_observation(
        output=response.content,
        level="DEFAULT",
    )
    return response.content
```

#### LangChain/LangGraph Integration
```python
from langfuse.callback import CallbackHandler

langfuse_handler = CallbackHandler(
    public_key=os.environ["LANGFUSE_PUBLIC_KEY"],
    secret_key=os.environ["LANGFUSE_SECRET_KEY"],
    host=os.environ.get("LANGFUSE_HOST", "http://localhost:3001"),
)

# Pass as callback to any LangChain/LangGraph invocation
result = await agent.ainvoke(
    {"input": query},
    config={"callbacks": [langfuse_handler]},
)
```

#### Prompt Management
```python
# Fetch versioned prompt from Langfuse
prompt = langfuse.get_prompt("agent-system-prompt", version=2)

# Use in LLM call
response = await llm.ainvoke(
    prompt.compile(agent_name="researcher", language="es"),
)
```

#### Scoring and Evaluation
```python
# Score a trace programmatically
langfuse.score(
    trace_id=trace_id,
    name="user-feedback",
    value=1,  # 1 = positive, 0 = negative
    comment="User marked as helpful",
)

# Create evaluation dataset
dataset = langfuse.create_dataset(name="contract-review-eval")
dataset.create_item(
    input={"query": "What are the termination clauses?"},
    expected_output="The contract can be terminated with 30 days notice...",
)
```

### 3. Best practices
- Use `@observe()` decorator on all functions in the LLM call chain
- Set `user_id` on traces for per-user cost tracking
- For self-hosted: use same PostgreSQL instance as your app (saves resources)
- Generate `NEXTAUTH_SECRET` and `SALT` with `openssl rand -base64 32`
- Enable `LANGFUSE_ENABLE_EXPERIMENTAL_FEATURES` for latest capabilities
- Use prompt management for version-controlled system prompts
- Flush traces on shutdown: `langfuse.flush()` in FastAPI lifespan
- For production: set `LANGFUSE_SAMPLE_RATE=0.5` to reduce storage on high-traffic
