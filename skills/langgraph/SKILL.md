---

name: langgraph

description: "Expert in LangGraph - the production-grade framework for building stateful, multi-actor AI applications. Covers graph construction, state management, cycles and branches, persistence with checkpointers, human-in-the-loop patterns, and the ReAct agent pattern. Used in production at LinkedIn, Uber, and 400+ companies. This is LangChain's recommended approach for building agents. Use when: langgraph, langchain agent, stateful agent, agent graph, react agent."

source: vibeship-spawner-skills (Apache 2.0)

---



\# LangGraph



\*\*Role\*\*: LangGraph Agent Architect



You are an expert in building production-grade AI agents with LangGraph. You

understand that agents need explicit structure - graphs make the flow visible

and debuggable. You design state carefully, use reducers appropriately, and

always consider persistence for production. You know when cycles are needed

and how to prevent infinite loops.



\## Capabilities



\- Graph construction (StateGraph)

\- State management and reducers

\- Node and edge definitions

\- Conditional routing

\- Checkpointers and persistence

\- Human-in-the-loop patterns

\- Tool integration

\- Streaming and async execution



\## Requirements



\- Python 3.9+

\- langgraph package

\- LLM API access (OpenAI, Anthropic, etc.)

\- Understanding of graph concepts



\## Patterns



\### Basic Agent Graph



Simple ReAct-style agent with tools



\*\*When to use\*\*: Single agent with tool calling



```python

from typing import Annotated, TypedDict

from langgraph.graph import StateGraph, START, END

from langgraph.graph.message import add\_messages

from langgraph.prebuilt import ToolNode

from langchain\_openai import ChatOpenAI

from langchain\_core.tools import tool



\# 1. Define State

class AgentState(TypedDict):

&nbsp;   messages: Annotated\[list, add\_messages]

&nbsp;   # add\_messages reducer appends, doesn't overwrite



\# 2. Define Tools

@tool

def search(query: str) -> str:

&nbsp;   """Search the web for information."""

&nbsp;   # Implementation here

&nbsp;   return f"Results for: {query}"



@tool

def calculator(expression: str) -> str:

&nbsp;   """Evaluate a math expression."""

&nbsp;   return str(eval(expression))



tools = \[search, calculator]



\# 3. Create LLM with tools

llm = ChatOpenAI(model="gpt-4o").bind\_tools(tools)



\# 4. Define Nodes

def agent(state: AgentState) -> dict:

&nbsp;   """The agent node - calls LLM."""

&nbsp;   response = llm.invoke(state\["messages"])

&nbsp;   return {"messages": \[response]}



\# Tool node handles tool execution

tool\_node = ToolNode(tools)



\# 5. Define Routing

def should\_continue(state: AgentState) -> str:

&nbsp;   """Route based on whether tools were called."""

&nbsp;   last\_message = state\["messages"]\[-1]

&nbsp;   if last\_message.tool\_calls:

&nbsp;       return "tools"

&nbsp;   return END



\# 6. Build Graph

graph = StateGraph(AgentState)



\# Add nodes

graph.add\_node("agent", agent)

graph.add\_node("tools", tool\_node)



\# Add edges

graph.add\_edge(START, "agent")

graph.add\_conditional\_edges("agent", should\_continue, \["tools", END])

graph.add\_edge("tools", "agent")  # Loop back



\# Compile

app = graph.compile()



\# 7. Run

result = app.invoke({

&nbsp;   "messages": \[("user", "What is 25 \* 4?")]

})

```



\### State with Reducers



Complex state management with custom reducers



\*\*When to use\*\*: Multiple agents updating shared state



```python

from typing import Annotated, TypedDict

from operator import add

from langgraph.graph import StateGraph



\# Custom reducer for merging dictionaries

def merge\_dicts(left: dict, right: dict) -> dict:

&nbsp;   return {\*\*left, \*\*right}



\# State with multiple reducers

class ResearchState(TypedDict):

&nbsp;   # Messages append (don't overwrite)

&nbsp;   messages: Annotated\[list, add\_messages]



&nbsp;   # Research findings merge

&nbsp;   findings: Annotated\[dict, merge\_dicts]



&nbsp;   # Sources accumulate

&nbsp;   sources: Annotated\[list\[str], add]



&nbsp;   # Current step (overwrites - no reducer)

&nbsp;   current\_step: str



&nbsp;   # Error count (custom reducer)

&nbsp;   errors: Annotated\[int, lambda a, b: a + b]



\# Nodes return partial state updates

def researcher(state: ResearchState) -> dict:

&nbsp;   # Only return fields being updated

&nbsp;   return {

&nbsp;       "findings": {"topic\_a": "New finding"},

&nbsp;       "sources": \["source1.com"],

&nbsp;       "current\_step": "researching"

&nbsp;   }



def writer(state: ResearchState) -> dict:

&nbsp;   # Access accumulated state

&nbsp;   all\_findings = state\["findings"]

&nbsp;   all\_sources = state\["sources"]



&nbsp;   return {

&nbsp;       "messages": \[("assistant", f"Report based on {len(all\_sources)} sources")],

&nbsp;       "current\_step": "writing"

&nbsp;   }



\# Build graph

graph = StateGraph(ResearchState)

graph.add\_node("researcher", researcher)

graph.add\_node("writer", writer)

\# ... add edges

```



\### Conditional Branching



Route to different paths based on state



\*\*When to use\*\*: Multiple possible workflows



```python

from langgraph.graph import StateGraph, START, END



class RouterState(TypedDict):

&nbsp;   query: str

&nbsp;   query\_type: str

&nbsp;   result: str



def classifier(state: RouterState) -> dict:

&nbsp;   """Classify the query type."""

&nbsp;   query = state\["query"].lower()

&nbsp;   if "code" in query or "program" in query:

&nbsp;       return {"query\_type": "coding"}

&nbsp;   elif "search" in query or "find" in query:

&nbsp;       return {"query\_type": "search"}

&nbsp;   else:

&nbsp;       return {"query\_type": "chat"}



def coding\_agent(state: RouterState) -> dict:

&nbsp;   return {"result": "Here's your code..."}



def search\_agent(state: RouterState) -> dict:

&nbsp;   return {"result": "Search results..."}



def chat\_agent(state: RouterState) -> dict:

&nbsp;   return {"result": "Let me help..."}



\# Routing function

def route\_query(state: RouterState) -> str:

&nbsp;   """Route to appropriate agent."""

&nbsp;   query\_type = state\["query\_type"]

&nbsp;   return query\_type  # Returns node name



\# Build graph

graph = StateGraph(RouterState)



graph.add\_node("classifier", classifier)

graph.add\_node("coding", coding\_agent)

graph.add\_node("search", search\_agent)

graph.add\_node("chat", chat\_agent)



graph.add\_edge(START, "classifier")



\# Conditional edges from classifier

graph.add\_conditional\_edges(

&nbsp;   "classifier",

&nbsp;   route\_query,

&nbsp;   {

&nbsp;       "coding": "coding",

&nbsp;       "search": "search",

&nbsp;       "chat": "chat"

&nbsp;   }

)



\# All agents lead to END

graph.add\_edge("coding", END)

graph.add\_edge("search", END)

graph.add\_edge("chat", END)



app = graph.compile()

```



\## Anti-Patterns



\### ❌ Infinite Loop Without Exit



\*\*Why bad\*\*: Agent loops forever.

Burns tokens and costs.

Eventually errors out.



\*\*Instead\*\*: Always have exit conditions:

\- Max iterations counter in state

\- Clear END conditions in routing

\- Timeout at application level



def should\_continue(state):

&nbsp;   if state\["iterations"] > 10:

&nbsp;       return END

&nbsp;   if state\["task\_complete"]:

&nbsp;       return END

&nbsp;   return "agent"



\### ❌ Stateless Nodes



\*\*Why bad\*\*: Loses LangGraph's benefits.

State not persisted.

Can't resume conversations.



\*\*Instead\*\*: Always use state for data flow.

Return state updates from nodes.

Use reducers for accumulation.

Let LangGraph manage state.



\### ❌ Giant Monolithic State



\*\*Why bad\*\*: Hard to reason about.

Unnecessary data in context.

Serialization overhead.



\*\*Instead\*\*: Use input/output schemas for clean interfaces.

Private state for internal data.

Clear separation of concerns.



\## Limitations



\- Python-only (TypeScript in early stages)

\- Learning curve for graph concepts

\- State management complexity

\- Debugging can be challenging



\## Related Skills



Works well with: `crewai`, `autonomous-agents`, `langfuse`, `structured-output`



