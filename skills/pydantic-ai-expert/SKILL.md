---
name: pydantic-ai-expert
description: Expert in PydanticAI framework for building type-safe AI agents with structured output, tool definitions, dependency injection, and multi-model support. Use when building agents with PydanticAI, defining tools, structured responses, or integrating with LangGraph worker nodes.
disable-model-invocation: true
---

# PydanticAI Expert

## When to use this skill
- Building AI agents with PydanticAI
- Defining type-safe tools and structured outputs
- Using dependency injection in agent context
- Integrating PydanticAI agents as LangGraph worker nodes
- Multi-model agent configurations
- Streaming structured responses

## When NOT to use
- LangGraph orchestration (use langgraph-architecture)
- Raw Pydantic models for data validation (not AI-specific)

## Instructions

### 1. Fetch up-to-date documentation
Use context7 MCP:
- `resolve-library-id` with libraryName: "pydantic-ai"
- `query-docs` for the specific topic

### 2. Core patterns from Agent Factory Stack

#### Basic Agent with Structured Output
```python
from pydantic import BaseModel
from pydantic_ai import Agent

class ResearchResult(BaseModel):
    summary: str
    key_findings: list[str]
    confidence: float
    sources: list[str]

researcher = Agent(
    "openai:gpt-4o-mini",
    result_type=ResearchResult,
    system_prompt="You are a research analyst. Always cite sources.",
)

result = await researcher.run("Analyze Q4 earnings for ACME Corp")
print(result.data)  # ResearchResult with typed fields
```

#### Agent with Tools and Dependencies
```python
from dataclasses import dataclass
from pydantic_ai import Agent, RunContext

@dataclass
class AgentDeps:
    db_pool: AsyncConnectionPool
    vector_store: QdrantClient
    tenant_id: str

agent = Agent(
    "openai:o3-mini",
    deps_type=AgentDeps,
    system_prompt="You are a contract review specialist.",
)

@agent.tool
async def search_contracts(ctx: RunContext[AgentDeps], query: str) -> list[dict]:
    """Search the contract database for relevant clauses."""
    results = ctx.deps.vector_store.search(
        collection_name="contracts",
        query_vector=await embed(query),
        query_filter={"tenant_id": ctx.deps.tenant_id},
        limit=5,
    )
    return [{"text": r.payload["text"], "score": r.score} for r in results]

@agent.tool
async def get_contract_metadata(ctx: RunContext[AgentDeps], contract_id: str) -> dict:
    """Get metadata for a specific contract."""
    row = await ctx.deps.db_pool.fetchrow(
        "SELECT * FROM contracts WHERE id = $1 AND tenant_id = $2",
        contract_id, ctx.deps.tenant_id,
    )
    return dict(row) if row else {"error": "not found"}
```

#### Multi-Model with Fallback
```python
from pydantic_ai.models.fallback import FallbackModel

model = FallbackModel(
    "openai:o3-mini",           # Primary: strong reasoning
    "openai:gpt-4o-mini",       # Fallback: faster, cheaper
)

supervisor = Agent(model, result_type=TaskPlan)
```

#### Integration as LangGraph Worker Node
```python
from langgraph.graph import StateGraph

async def researcher_node(state: AgentState) -> AgentState:
    result = await researcher.run(
        state["current_task"],
        deps=AgentDeps(db_pool=state["db_pool"], vector_store=state["vs"], tenant_id=state["tenant"]),
    )
    return {"research_output": result.data}

graph = StateGraph(AgentState)
graph.add_node("researcher", researcher_node)
```

### 3. Best practices
- Always define `result_type` with a Pydantic model — never use unstructured output
- Use `deps_type` for database connections, API clients, tenant context
- Tools decorated with `@agent.tool` get automatic type validation
- For expensive operations: use `@agent.tool(retries=2)` for automatic retry
- Use `FallbackModel` for production resilience (primary + cheaper fallback)
- Keep agents focused: one responsibility per agent, compose via LangGraph
- Use `result_validator` for business-rule validation on agent outputs
- Streaming: `async for chunk in agent.run_stream(prompt, deps=deps):`
