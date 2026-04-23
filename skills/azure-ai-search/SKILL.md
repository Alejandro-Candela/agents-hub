---
name: azure-ai-search
description: Expert in Azure AI Search (formerly Cognitive Search) including index creation, hybrid search with semantic ranker, vectorizers, skillsets, integrated vectorization, and RBAC. Use when configuring search indices, implementing hybrid/semantic search on Azure, or building RAG pipelines with Azure AI Search.
---

# Azure AI Search Expert

## When to use this skill
- Creating or modifying Azure AI Search indices
- Configuring hybrid search (BM25 + vector + semantic ranker)
- Setting up integrated vectorization with Azure OpenAI
- Building skillsets for document enrichment
- Configuring RBAC and API key management
- Optimizing search relevance and performance

## When NOT to use
- Elasticsearch (use elasticsearch-expert)
- Qdrant or other standalone vector DBs (use qdrant-expert)
- General Azure infrastructure (use azure-verified-modules)

## Instructions

### 1. Fetch up-to-date documentation
Use context7 MCP or microsoft-docs MCP:
- `resolve-library-id` with libraryName: "azure-search-documents"
- Or use `microsoft_docs_search` for Azure AI Search topics

### 2. Core patterns from Azure Enterprise Stack

#### Index with Hybrid Search
```python
from azure.search.documents.indexes.models import (
    SearchIndex, SearchField, SearchFieldDataType,
    VectorSearch, HnswAlgorithmConfiguration,
    VectorSearchProfile, AzureOpenAIVectorizer,
    AzureOpenAIVectorizerParameters,
    SemanticConfiguration, SemanticSearch,
    SemanticPrioritizedFields, SemanticField,
)

index = SearchIndex(
    name="documents",
    fields=[
        SearchField(name="id", type=SearchFieldDataType.String, key=True),
        SearchField(name="content", type=SearchFieldDataType.String, searchable=True, analyzer_name="es.microsoft"),
        SearchField(name="content_vector", type=SearchFieldDataType.Collection(SearchFieldDataType.Single),
                    searchable=True, vector_search_dimensions=3072, vector_search_profile_name="default-profile"),
        SearchField(name="source", type=SearchFieldDataType.String, filterable=True, facetable=True),
        SearchField(name="tenant_id", type=SearchFieldDataType.String, filterable=True),
    ],
    vector_search=VectorSearch(
        algorithms=[HnswAlgorithmConfiguration(name="default-hnsw", parameters={"m": 4, "efConstruction": 400, "efSearch": 500})],
        profiles=[VectorSearchProfile(name="default-profile", algorithm_configuration_name="default-hnsw",
                                       vectorizer_name="openai-vectorizer")],
        vectorizers=[AzureOpenAIVectorizer(
            vectorizer_name="openai-vectorizer",
            parameters=AzureOpenAIVectorizerParameters(
                resource_url=os.environ["AZURE_OPENAI_ENDPOINT"],
                deployment_name="text-embedding-3-large",
                model_name="text-embedding-3-large",
            ),
        )],
    ),
    semantic_search=SemanticSearch(
        configurations=[SemanticConfiguration(
            name="default-semantic",
            prioritized_fields=SemanticPrioritizedFields(
                content_fields=[SemanticField(field_name="content")],
            ),
        )],
    ),
)
```

#### Hybrid Search Query
```python
from azure.search.documents import SearchClient
from azure.search.documents.models import VectorizableTextQuery

client = SearchClient(endpoint, index_name, credential)

results = client.search(
    search_text="contrato de arrendamiento",
    vector_queries=[
        VectorizableTextQuery(
            text="contrato de arrendamiento",
            k_nearest_neighbors=10,
            fields="content_vector",
        )
    ],
    query_type="semantic",
    semantic_configuration_name="default-semantic",
    filter=f"tenant_id eq '{tenant_id}'",
    top=10,
)
```

#### Terraform Provisioning
```hcl
resource "azurerm_search_service" "search" {
  name                = "search-${var.project}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "standard"
  replica_count       = 1
  partition_count     = 1

  identity {
    type = "SystemAssigned"
  }
}
```

### 3. Best practices
- Always enable semantic ranker for production RAG — improves relevance significantly
- Use `VectorizableTextQuery` for integrated vectorization (no client-side embedding needed)
- Use `es.microsoft` analyzer for Spanish content (better than default)
- Filter on `keyword`-type fields for multi-tenancy
- Set RBAC with Managed Identity (not API keys) for production
- Standard tier minimum for semantic ranker and vector search
- Use `scoring_profiles` to boost recent documents or specific sources
- For large datasets: partition count > 1 for parallel query execution
