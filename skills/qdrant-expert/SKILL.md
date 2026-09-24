---
name: qdrant-expert
description: Expert in Qdrant vector database including collection management, HNSW indexing, payload filtering, multi-tenancy, quantization, and hybrid search. Use when configuring Qdrant, creating collections, optimizing search, or implementing vector storage for RAG pipelines.
disable-model-invocation: true
---

# Qdrant Expert

## When to use this skill
- Creating/configuring Qdrant collections
- Implementing vector search with payload filtering
- Setting up multi-tenancy (one collection, filtered by tenant)
- Optimizing HNSW parameters for recall vs speed
- Configuring scalar/product quantization
- Docker deployment and clustering

## When NOT to use
- Elasticsearch vector search (use elasticsearch-expert)
- Azure AI Search (use azure-ai-search)
- Pinecone or pgvector

## Instructions

### 1. Fetch up-to-date documentation
Use context7 MCP:
- `resolve-library-id` with libraryName: "qdrant"
- `query-docs` for the specific topic

### 2. Core patterns from Golden Stacks

#### Docker Compose
```yaml
qdrant:
  image: qdrant/qdrant:latest
  ports:
    - "6333:6333"   # REST API
    - "6334:6334"   # gRPC
  volumes:
    - qdrant-data:/qdrant/storage
  environment:
    - QDRANT__SERVICE__GRPC_PORT=6334
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:6333/healthz"]
    interval: 10s
    timeout: 5s
    retries: 3
```

#### Collection Creation (Python)
```python
from qdrant_client import QdrantClient
from qdrant_client.models import (
    Distance, VectorParams, HnswConfigDiff,
    QuantizationConfig, ScalarQuantization, ScalarType,
    PayloadSchemaType,
)

client = QdrantClient(host="localhost", port=6333)

client.create_collection(
    collection_name="documents",
    vectors_config=VectorParams(
        size=1536,          # text-embedding-3-small dimension
        distance=Distance.COSINE,
        hnsw_config=HnswConfigDiff(
            m=16,
            ef_construct=100,
        ),
        quantization_config=ScalarQuantization(
            scalar=ScalarType(type="int8", quantile=0.99, always_ram=True),
        ),
    ),
)

# Create payload index for filtering
client.create_payload_index(
    collection_name="documents",
    field_name="tenant_id",
    field_schema=PayloadSchemaType.KEYWORD,
)
```

#### Upsert with Payload
```python
from qdrant_client.models import PointStruct

client.upsert(
    collection_name="documents",
    points=[
        PointStruct(
            id=uuid4().hex,
            vector=embedding,
            payload={
                "text": chunk_text,
                "source": "contract_v2.pdf",
                "page": 3,
                "tenant_id": "client-acme",
            },
        )
    ],
)
```

#### Search with Filter
```python
from qdrant_client.models import Filter, FieldCondition, MatchValue

results = client.search(
    collection_name="documents",
    query_vector=query_embedding,
    query_filter=Filter(
        must=[
            FieldCondition(key="tenant_id", match=MatchValue(value="client-acme")),
        ]
    ),
    limit=10,
    score_threshold=0.7,
)
```

### 3. Best practices
- Use `COSINE` distance for normalized embeddings (OpenAI, Cohere)
- HNSW: `m=16, ef_construct=100` is a solid default; increase `m` for higher recall
- Enable scalar quantization (`int8`) to reduce memory 4x with <1% recall loss
- Multi-tenancy: use payload filter on `tenant_id` (not separate collections)
- Create payload indices on ALL fields you filter by
- Use gRPC (port 6334) for production — faster than REST
- Set `score_threshold` to avoid returning irrelevant results
- For production: set `QDRANT__STORAGE__WAL__WAL_CAPACITY_MB=64`

## RAG Pipeline Conventions (cross-cutting)

Architecture: Documents → Ingestion → Chunking → Embedding → Vector Store, then Query → Retrieval → Reranking → Generation.

- Chunking: 512 tokens / 64 overlap default; semantic chunking for unstructured text; never chunk across document boundaries; preserve source/page/section/timestamp metadata
- Embeddings: Azure OpenAI `text-embedding-3-large` (3072 dims, reduce to 1536 if storage-constrained) for production; `nomic-embed-text` via Ollama for local dev; always normalize for cosine similarity
- Vector store choice: Qdrant (default, self-hosted), Azure AI Search (already on Azure, hybrid + semantic ranker), Elasticsearch (when full-text search also needed)
- Retrieval: hybrid vector + BM25 with RRF fusion; top-k 10 candidates reranked to 3-5 for context; always filter by source/tenant before similarity search (prevents cross-tenant leaks)
- Generation: cite sources, temperature 0-0.3 for factual answers, always instruct "if you don't know, say so"
- Eval: faithfulness, relevance, context precision, answer correctness — track retrieval hit rate separately from generation quality
