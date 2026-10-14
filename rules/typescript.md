---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---
# TypeScript / JavaScript

Adapted from ECC `rules/typescript/` (https://github.com/affaan-m/ECC/tree/b92f181b3b748d1abbc2afd94af6aa7d8c8fca29/rules/typescript, MIT).

- **Tooling**: `bun` for install, scripts and tests (`bun add`, `bun run`, `bun test`, `bun x`). Never npm/npx.
- **Types**: explicit parameter and return types on exported functions and public methods; let inference handle locals. `interface` for extendable object shapes, `type` for unions and utilities. String literal unions over `enum`.
- **No `any`**: use `unknown` for external input and narrow it. Generics when the type depends on the caller.
- **Validation**: Zod at trust boundaries (request bodies, env, LLM outputs); derive types with `z.infer` instead of duplicating them.
- **React**: props as a named `interface`/`type`; type callback props; no `React.FC`.
- **Data**: prefer immutable updates (spread, `Readonly<T>`) for shared state.
- **Errors**: catch as `unknown` and narrow; only catch where you can add context or recover.
- **Logging**: no `console.log` left in production code.
- **Secrets**: from `process.env`, checked at startup; never hardcoded or logged.
- **E2E**: Playwright for critical user flows.
