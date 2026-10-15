---
paths:
  - "**/*.py"
  - "**/*.pyi"
---
# Python

Adapted from ECC `rules/python/` (https://github.com/affaan-m/ECC/tree/b92f181b3b748d1abbc2afd94af6aa7d8c8fca29/rules/python, MIT).

- **Tooling**: `uv` for environments, dependencies and running tools (`uv add`, `uv run pytest`). Never `pip install`.
- **Formatting and lint**: `ruff format` + `ruff check` (the format-after-edit hook already runs both). No black, no isort.
- **Types**: annotate every function signature you write. Prefer `X | None` over `Optional[X]`, `Protocol` over ABCs for duck typing.
- **Data**: prefer `@dataclass(frozen=True)` or Pydantic models for structured data over loose dicts. Use Pydantic at I/O boundaries (API payloads, LLM outputs, config).
- **Resources**: context managers for anything that must be closed; generators for large or streamed sequences.
- **Tests**: pytest via `uv run pytest`. Mark slow or external tests (`@pytest.mark.integration`) so the default run stays fast. Coverage: `uv run pytest --cov=<pkg> --cov-report=term-missing` when asked for it.
- **Secrets**: read from the environment and fail fast when missing (`os.environ["KEY"]`, or `pydantic-settings`). Never hardcode, never log.
- **Security scan** when asked: `uv run --with bandit bandit -r <pkg>`.
