---
name: langgraph
description: >-
  LangGraph architecture, implementation, and code review guide for stateful, multi-actor AI agents. Covers StateGraph design, TypedDict/Pydantic schemas, reducers (add_messages, operator.add), conditional edges vs Command, checkpointers (PostgresSaver, SqliteSaver), human-in-the-loop interrupts, streaming modes, multi-agent patterns (supervisor, handoff), and the 20-point anti-pattern review checklist.
disable-model-invocation: true
---

# LangGraph Architecture, Docs & Code Review

## Official Documentation Index

When verifying current LangGraph Python/JS APIs, fetch the live documentation index first:
- `https://docs.langchain.com/llms.txt` (or query `langgraph` via context7 MCP).

---

## Part 1: Architecture Decisions

### When to Use LangGraph vs Alternatives

| Scenario | Recommended | Why |
|----------|-------------|-----|
| Stateful multi-turn agents, loops, HITL interrupts, persistence | **LangGraph** | Explicit graph control flow, checkpointing, time-travel |
| Single LLM call / structured output | Direct SDK / PydanticAI | Graph overhead not justified |
| Simple linear chain | Direct async functions | Simpler control flow |

### State Schema & Reducers

- Prefer `TypedDict` for lightweight state; use `Pydantic` when runtime validation at boundaries is required.
- Keep state small (< 1 MB); store large documents/payloads in `BaseStore` and pass reference IDs in state.

| Use Case | Reducer | Example |
|----------|---------|---------|
| Chat messages | `add_messages` | `messages: Annotated[list, add_messages]` |
| Append list | `operator.add` | `items: Annotated[list, operator.add]` |
| Keep latest | None (LastValue) | `step: str` |
| Bypass reducer | `Overwrite` | `Overwrite(new_list)` |

### Routing: Conditional Edges vs `Command`

```python
# Conditional Edge — pure routing
def router(state: State) -> Literal["tools", "__end__"]:
    return "tools" if state["needs_tool"] else END

builder.add_conditional_edges("agent", router)

# Command — routing + state update in one step (declare destinations on add_node!)
def node(state: State) -> Command[Literal["next", "__end__"]]:
    return Command(goto="next", update={"step": state["step"] + 1})

builder.add_node("node", node, destinations=["next", END])
```

### Persistence & Checkpointers

- **`InMemorySaver`**: unit tests only (lost on restart).
- **`SqliteSaver`**: local development / CLI tools.
- **`PostgresSaver`**: production (`PostgresSaver.from_conn_string(conn_string)`).
- **Subgraphs**: `compile(checkpointer=None)` inherits parent checkpointer; `checkpointer=True` gives independent namespace; `checkpointer=False` runs atomically without persistence.

### Streaming & Human-in-the-Loop

- **Stream modes**: `updates` (node deltas), `values` (full state), `messages` (LLM tokens), `custom` (`StreamWriter` events), `debug` (tasks + checkpoints). Pass `subgraphs=True` to include subgraph events.
- **Interrupts**: Use `interrupt("prompt")` inside a node (requires a checkpointer + `configurable.thread_id`) and resume via `graph.invoke(Command(resume=value), config)`. Disable `parallel_tool_calls=False` on models bound to tools that trigger interrupts.

---

## Part 2: Code Review & Anti-Pattern Checklist

When writing or reviewing LangGraph code, verify these 10 critical invariants:

1. **Never mutate state in-place**: nodes must return partial dicts (`return {"messages": [msg]}`), never `state["messages"].append(msg)`.
2. **Every list/collection field that accumulates across nodes has a reducer**: `Annotated[list, add_messages]` or `Annotated[list, operator.add]` (including on Pydantic `BaseModel` states).
3. **Return only changed fields**: never return `{**state, "counter": state["counter"] + 1}`, which unnecessarily re-writes unchanged keys.
4. **Type-annotate routers with `Literal[..., "__end__"]`**: return the `END` constant, never unvalidated strings, and ensure `add_conditional_edges` maps every possible return value.
5. **Declare `destinations=[...]` when a node returns `Command`**: otherwise graph visualization and static validation cannot see outgoing edges.
6. **Checkpointer + `thread_id` whenever using `interrupt()`**: calling `interrupt()` without a compiled checkpointer or invoking without `{"configurable": {"thread_id": "..."}}` fails at runtime.
7. **Every `AIMessage.tool_calls` entry is paired with a `ToolMessage`**: unpaired tool calls cause the next LLM invocation to fail.
8. **Async nodes (`async def`) use `await graph.ainvoke()` / `graph.astream()` and non-blocking I/O (`httpx.AsyncClient`)**: never call `requests.get()` or `time.sleep()` inside an async node.
9. **Never ship `InMemorySaver` to production**: use `PostgresSaver` and keep large blobs in `BaseStore` rather than checkpointed state.
10. **Bound cyclic graphs**: configure `{"recursion_limit": N}` or track `RemainingSteps` in state so tool/agent loops cannot spin infinitely.
