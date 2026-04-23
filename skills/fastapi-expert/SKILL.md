---
name: fastapi-expert
description: Expert in FastAPI development including async endpoints, dependency injection, Pydantic models, middleware, lifespan events, WebSocket, streaming responses, and production deployment. Use when building APIs, adding endpoints, configuring middleware, or debugging FastAPI applications.
---

# FastAPI Expert

## When to use this skill
- Creating or modifying FastAPI endpoints
- Configuring middleware (CORS, auth, rate limiting)
- Setting up dependency injection patterns
- Implementing WebSocket or SSE streaming
- Configuring lifespan events (startup/shutdown)
- Pydantic model validation and serialization
- Production deployment with uvicorn/gunicorn

## When NOT to use
- Frontend/UI work (use webapp-testing)
- Django, Flask, or other frameworks

## Instructions

### 1. Fetch up-to-date documentation
Use context7 MCP:
- `resolve-library-id` with libraryName: "fastapi"
- `query-docs` for the specific topic

### 2. Core patterns used in Golden Stacks

#### Application Factory (standard entry point)
```python
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: init DB pool, load models, connect to vector DB
    app.state.db = await init_db_pool()
    app.state.vector_store = await connect_vector_store()
    yield
    # Shutdown: cleanup
    await app.state.db.close()

def create_app() -> FastAPI:
    app = FastAPI(
        title="Agent API",
        version="1.0.0",
        lifespan=lifespan,
    )
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.include_router(agent_router, prefix="/api/v1")
    app.include_router(health_router)
    return app

app = create_app()
```

#### Streaming Response (for LLM output)
```python
from fastapi.responses import StreamingResponse

@router.post("/chat")
async def chat(request: ChatRequest):
    async def generate():
        async for chunk in agent.astream(request.message):
            yield f"data: {chunk.model_dump_json()}\n\n"
        yield "data: [DONE]\n\n"
    return StreamingResponse(generate(), media_type="text/event-stream")
```

#### Dependency Injection (settings + auth)
```python
from functools import lru_cache
from fastapi import Depends, HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()

@lru_cache
def get_settings():
    return Settings()

async def verify_token(
    credentials: HTTPAuthorizationCredentials = Security(security),
    settings: Settings = Depends(get_settings),
) -> dict:
    payload = jwt.decode(credentials.credentials, settings.jwt_secret, algorithms=["HS256"])
    return payload

@router.get("/protected")
async def protected(user: dict = Depends(verify_token)):
    return {"user": user}
```

#### Health Check Endpoint
```python
@router.get("/health")
async def health():
    return {"status": "ok"}

@router.get("/health/ready")
async def readiness(db=Depends(get_db)):
    await db.execute("SELECT 1")
    return {"status": "ready"}
```

### 3. Best practices
- Always use `lifespan` (not deprecated `on_event`)
- Use `async def` for I/O-bound endpoints, `def` for CPU-bound (runs in threadpool)
- Return Pydantic models for automatic serialization and OpenAPI docs
- Use `status_code=201` for POST that creates resources
- Use `HTTPException` for errors, not bare `raise`
- Set `response_model` on endpoints for automatic filtering of extra fields
- Use `Annotated[Type, Depends(...)]` syntax (modern pattern)
- For production: `uvicorn app:app --workers 4 --host 0.0.0.0 --port 8080`
