---
name: presidio-dlp
description: Expert in Microsoft Presidio for PII detection and redaction including custom recognizers, anonymizers, and integration with NLP pipelines. Use when implementing DLP, PII filtering, data anonymization, GDPR compliance, or privacy controls in agent pipelines.
---

# Presidio DLP Expert

## When to use this skill
- Implementing PII detection/redaction in agent pipelines
- Creating custom entity recognizers (NIF, IBAN, etc.)
- Configuring anonymization strategies (redact, mask, encrypt, hash)
- Integrating Presidio with FastAPI middleware
- GDPR/ENS-Alto compliance data filtering
- Filtering PII from OCR outputs before indexing

## When NOT to use
- General security hardening (use devops-troubleshooter)
- Azure Content Safety (use azure-ai-foundry)

## Instructions

### 1. Fetch up-to-date documentation
Use context7 MCP:
- `resolve-library-id` with libraryName: "presidio"
- `query-docs` for the specific topic

### 2. Core patterns from Golden Stacks

#### Basic Analyzer + Anonymizer
```python
from presidio_analyzer import AnalyzerEngine
from presidio_anonymizer import AnonymizerEngine
from presidio_anonymizer.entities import OperatorConfig

analyzer = AnalyzerEngine()
anonymizer = AnonymizerEngine()

# Detect PII
results = analyzer.analyze(
    text="Mi nombre es Juan Garcia, email: juan@empresa.com, NIF: 12345678A",
    language="es",
    entities=["PERSON", "EMAIL_ADDRESS", "PHONE_NUMBER", "IBAN_CODE"],
)

# Anonymize with custom operators
anonymized = anonymizer.anonymize(
    text=text,
    analyzer_results=results,
    operators={
        "PERSON": OperatorConfig("replace", {"new_value": "[REDACTED]"}),
        "EMAIL_ADDRESS": OperatorConfig("mask", {"chars_to_mask": 6, "masking_char": "*", "from_end": False}),
        "DEFAULT": OperatorConfig("replace", {"new_value": "[PII]"}),
    },
)
```

#### Custom Recognizer (Spanish NIF)
```python
from presidio_analyzer import PatternRecognizer, Pattern

nif_recognizer = PatternRecognizer(
    supported_entity="ES_NIF",
    name="Spanish NIF Recognizer",
    patterns=[
        Pattern(
            name="nif_pattern",
            regex=r"\b\d{8}[A-Z]\b",
            score=0.85,
        )
    ],
    supported_language="es",
)

analyzer.registry.add_recognizer(nif_recognizer)
```

#### FastAPI Middleware Integration
```python
from fastapi import Request, Response

class PresidioDLPMiddleware:
    def __init__(self, app, analyzer: AnalyzerEngine, anonymizer: AnonymizerEngine):
        self.app = app
        self.analyzer = analyzer
        self.anonymizer = anonymizer

    async def __call__(self, scope, receive, send):
        if scope["type"] == "http":
            request = Request(scope, receive)
            body = await request.body()
            # Redact PII from request body
            clean_body = self._redact(body.decode())
            # ... continue with clean body
        await self.app(scope, receive, send)

    def _redact(self, text: str) -> str:
        results = self.analyzer.analyze(text=text, language="es")
        return self.anonymizer.anonymize(text=text, analyzer_results=results).text
```

#### Docker Compose Service
```yaml
presidio-analyzer:
  image: mcr.microsoft.com/presidio-analyzer:latest
  ports:
    - "5001:3000"

presidio-anonymizer:
  image: mcr.microsoft.com/presidio-anonymizer:latest
  ports:
    - "5002:3000"
```

### 3. Best practices
- Apply PII redaction on BOTH inputs and outputs (bidirectional)
- For OCR pipelines: redact at OCR stage BEFORE indexing in vector DB
- Use `score_threshold=0.7` minimum to reduce false positives
- Custom recognizers: keep patterns simple, validate with test suite
- For Spanish entities: add NIF, CIF, IBAN ES patterns as custom recognizers
- In production: use the REST API (Docker images) for language isolation
- Cache AnalyzerEngine instance (expensive to initialize)
- Log redaction stats but NEVER log the original PII text
