---
name: elasticsearch-expert
description: Expert in Elasticsearch 8.x including index management, hybrid search (BM25 + kNN + ELSER), mappings, analyzers, aggregations, and production tuning. Use when configuring Elasticsearch indices, implementing hybrid/semantic search, setting up ELSER sparse vectors, or debugging search relevance.
---

# Elasticsearch Expert

## When to use this skill
- Creating indices with hybrid search (dense + sparse + BM25)
- Configuring ELSER v2 for learned sparse retrieval
- Setting up kNN vector search with HNSW
- Writing complex queries with RRF (Reciprocal Rank Fusion)
- Tuning analyzers for multilingual content
- Managing index lifecycle and performance

## When NOT to use
- Azure AI Search (use azure-ai-search)
- Qdrant or other vector-only DBs (use qdrant-expert)
- ELK for log aggregation (use devops-troubleshooter)

## Instructions

### 1. Fetch up-to-date documentation
Use context7 MCP:
- `resolve-library-id` with libraryName: "elasticsearch"
- `query-docs` for the specific topic

### 2. Core patterns from Multimodal RAG Stack

#### Hybrid Index Mapping
```json
{
  "mappings": {
    "properties": {
      "text": {
        "type": "text",
        "analyzer": "spanish_custom"
      },
      "embedding": {
        "type": "dense_vector",
        "dims": 3072,
        "index": true,
        "similarity": "cosine",
        "index_options": {
          "type": "hnsw",
          "m": 16,
          "ef_construction": 100
        }
      },
      "ml.tokens": {
        "type": "sparse_vector"
      },
      "source_file": { "type": "keyword" },
      "page_number": { "type": "integer" },
      "bbox": {
        "type": "object",
        "properties": {
          "x": { "type": "float" },
          "y": { "type": "float" },
          "width": { "type": "float" },
          "height": { "type": "float" }
        }
      },
      "tenant_id": { "type": "keyword" },
      "created_at": { "type": "date" }
    }
  },
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0,
    "analysis": {
      "analyzer": {
        "spanish_custom": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": ["lowercase", "spanish_stop", "spanish_stemmer"]
        }
      },
      "filter": {
        "spanish_stop": { "type": "stop", "stopwords": "_spanish_" },
        "spanish_stemmer": { "type": "stemmer", "language": "spanish" }
      }
    }
  }
}
```

#### Hybrid Search with RRF
```json
{
  "retriever": {
    "rrf": {
      "retrievers": [
        {
          "standard": {
            "query": {
              "match": { "text": "contrato de arrendamiento" }
            }
          }
        },
        {
          "knn": {
            "field": "embedding",
            "query_vector": [0.1, 0.2, ...],
            "k": 10,
            "num_candidates": 50
          }
        },
        {
          "standard": {
            "query": {
              "sparse_vector": {
                "field": "ml.tokens",
                "inference_id": "elser-v2",
                "query": "lease agreement terms"
              }
            }
          }
        }
      ],
      "rank_window_size": 50,
      "rank_constant": 60
    }
  },
  "size": 10
}
```

#### ELSER v2 Setup
```python
# Deploy ELSER model
es.ml.put_trained_model(
    model_id=".elser_model_2_linux-x86_64",
    input={"field_names": ["text_field"]},
)
es.ml.start_trained_model_deployment(
    model_id=".elser_model_2_linux-x86_64",
    number_of_allocations=1,
    threads_per_allocation=2,
)

# Create inference endpoint
es.inference.put(
    inference_id="elser-v2",
    task_type="sparse_embedding",
    body={
        "service": "elser",
        "service_settings": {
            "model_id": ".elser_model_2_linux-x86_64",
            "num_allocations": 1,
        }
    }
)
```

#### Docker Compose
```yaml
elasticsearch:
  image: docker.elastic.co/elasticsearch/elasticsearch:8.15.0
  environment:
    - discovery.type=single-node
    - xpack.security.enabled=true
    - ELASTIC_PASSWORD=${ELASTICSEARCH_PASSWORD}
    - xpack.ml.enabled=true
    - xpack.ml.use_auto_machine_memory_percent=true
  ports:
    - "9200:9200"
  volumes:
    - es-data:/usr/share/elasticsearch/data
  mem_limit: 4g
```

### 3. Best practices
- RRF (Reciprocal Rank Fusion) is the recommended way to combine BM25 + kNN + ELSER
- Set `rank_constant: 60` as default (standard for most use cases)
- For multilingual: use language-specific analyzers per field
- ELSER v2 requires `xpack.ml.enabled=true` and ~2GB RAM for model
- Always use `keyword` type for filterable fields (not `text`)
- For large indices: use ILM (Index Lifecycle Management) with rollover
- Set `number_of_replicas: 0` for dev, `1` for production
- Use `_source: false` with `stored_fields` to reduce storage for large datasets
