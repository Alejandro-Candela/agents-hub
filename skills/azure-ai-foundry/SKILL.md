---
name: azure-ai-foundry
description: Expert in Azure AI Foundry (formerly Azure AI Studio) including model deployments (GPT-4o, o3-mini, Phi-4), prompt flow, content safety, evaluations, and managed endpoints. Use when deploying models on Azure, configuring content safety, building prompt flows, or managing AI projects on Azure.
disable-model-invocation: true
---

# Azure AI Foundry Expert

## When to use this skill
- Deploying models on Azure AI Foundry (serverless or managed compute)
- Configuring Azure AI Content Safety thresholds
- Building and deploying prompt flows
- Running evaluations and benchmarks
- Managing AI projects, hubs, and connections
- Choosing between serverless vs dedicated endpoints

## When NOT to use
- OpenAI direct API (not Azure-hosted)
- vLLM local inference (use vllm-expert)
- Azure DevOps CI/CD (use azure-devops-cli)

## Instructions

### 1. Fetch up-to-date documentation
Use context7 MCP or microsoft-docs MCP:
- `resolve-library-id` with libraryName: "azure-ai-projects"
- Or `microsoft_docs_search` for Azure AI Foundry topics

### 2. Core patterns from Azure Enterprise Stack

#### Model Deployment Types
| Type | Models | Billing | Best For |
|---|---|---|---|
| Serverless (MaaS) | GPT-4o, o3-mini, Llama 3.3 | Pay-per-token | Variable workloads |
| Managed Compute | Phi-4, fine-tuned models | Per-hour | Consistent workloads |
| Global Standard | GPT-4o, GPT-4o-mini | Pay-per-token | Highest availability |

#### Python SDK Usage
```python
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential

project = AIProjectClient(
    credential=DefaultAzureCredential(),
    endpoint=os.environ["AZURE_AI_PROJECT_ENDPOINT"],
)

# Chat completion
response = project.inference.get_chat_completions_client().complete(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "Eres un asistente empresarial."},
        {"role": "user", "content": user_message},
    ],
    temperature=0.7,
    max_tokens=1024,
)
```

#### Content Safety Configuration
```python
from azure.ai.contentsafety import ContentSafetyClient
from azure.ai.contentsafety.models import AnalyzeTextOptions, TextCategory

client = ContentSafetyClient(endpoint, credential)

result = client.analyze_text(AnalyzeTextOptions(
    text=user_input,
    categories=[
        TextCategory.HATE,
        TextCategory.VIOLENCE,
        TextCategory.SELF_HARM,
        TextCategory.SEXUAL,
    ],
))

# Block if severity >= threshold
for category in result.categories_analysis:
    if category.severity >= settings.content_safety_threshold:
        raise ContentBlockedError(f"Blocked: {category.category} severity {category.severity}")
```

#### Terraform Provisioning
```hcl
resource "azurerm_ai_services" "ai" {
  name                = "ai-${var.project}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "S0"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_cognitive_deployment" "gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_ai_services.ai.id

  model {
    format  = "OpenAI"
    name    = "gpt-4o"
    version = "2024-11-20"
  }

  sku {
    name     = "GlobalStandard"
    capacity = 30  # TPM in thousands
  }
}
```

#### Using with LangChain/LangGraph
```python
from langchain_openai import AzureChatOpenAI

llm = AzureChatOpenAI(
    azure_deployment="gpt-4o",
    azure_endpoint=os.environ["AZURE_OPENAI_ENDPOINT"],
    api_version="2024-10-21",
    temperature=0.7,
)
```

### 3. Best practices
- Use Managed Identity (`DefaultAzureCredential`) — never API keys in production
- Content Safety: set threshold at 2 (moderate) for enterprise, 0 (strict) for public-facing
- For o3-mini: use `reasoning_effort: "medium"` to balance cost/quality
- Deploy in EU regions (westeurope, swedencentral) for GDPR compliance
- Use Global Standard deployment for highest availability
- Set TPM (tokens per minute) quota based on expected peak load
- Enable prompt flow tracing with Application Insights for debugging
- For evaluations: use Azure AI Evaluation SDK with built-in metrics (groundedness, relevance, fluency)

## Cross-Cutting Azure Conventions

These apply beyond AI Foundry to any Azure resource in the project:

- Naming: `{project}-{env}-{resource}-{region}` (e.g. `myapp-prod-func-westeu`); resource groups `rg-{project}-{env}`; lowercase, hyphens only, under 24 chars for storage accounts
- dev/staging/prod each get their own resource group; Azure Developer CLI (`azd`) for provisioning; Bicep for IaC (preferred over Terraform unless AVM required)
- Key Vault: one per environment, all secrets/connection strings/API keys go there, referenced via `@Microsoft.KeyVault()` — never connection strings in code, always managed identity
- Deployment: staging slot for zero-downtime, swap after health check passes, never deploy directly to production
