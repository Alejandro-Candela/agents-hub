// Runs advisory Claude Code hook scripts from OpenCode. Those scripts answer
// with `additionalContext`; OpenCode has no context-injection equivalent for
// tool calls, so the text is appended to the tool's output instead, which is
// what the model reads next. Blocking hooks have their own plugins
// (pre-push-public-check.ts, sensitive-file-guard.ts).
//
//   write/edit      -> format-after-edit.sh
//   bash            -> package-manager-nudge.sh
//   bash git add/commit -> pre-tool-git-check.sh
//   compaction      -> precompact-state.sh
//
// Deliberately not bridged: truncate-stdout (OpenCode truncates natively),
// filter-test-output, session-orient, post-error-adviser, session-reflect
// (Claude-specific content or no OpenCode event). See README.

import { homedir } from "node:os"
import { join } from "node:path"

type Shell = typeof import("bun").$

interface PluginInput {
  $: Shell
  directory: string
}

interface AfterInput {
  tool: string
  args: { command?: string; filePath?: string }
}

interface AfterOutput {
  output: string
}

interface CompactingOutput {
  context: string[]
}

interface Hooks {
  "tool.execute.after": (input: AfterInput, output: AfterOutput) => Promise<void>
  "experimental.session.compacting": (input: unknown, output: CompactingOutput) => Promise<void>
}

const HOOKS = join(homedir(), ".claude/hooks")
const GIT_STAGE = /(^|[;&|\s])git\s+(add|commit)(\s|$)/

export const ClaudeHooksBridge = async ({ $, directory }: PluginInput): Promise<Hooks> => {
  const context = async (script: string, payload: object): Promise<string | undefined> => {
    const stdin = new Response(JSON.stringify(payload))
    const text = await $`bash ${join(HOOKS, script)} < ${stdin}`
      .cwd(directory)
      .env({ ...process.env, CLAUDE_PROJECT_DIR: directory })
      .quiet()
      .nothrow()
      .text()
    try {
      const value: unknown = JSON.parse(text || "{}")?.hookSpecificOutput?.additionalContext
      return typeof value === "string" ? value : undefined
    } catch {
      return undefined // a hook that prints non-JSON must never break the tool call
    }
  }

  return {
    "tool.execute.after": async (input: AfterInput, output: AfterOutput): Promise<void> => {
      const notes: (string | undefined)[] = []
      if ((input.tool === "write" || input.tool === "edit") && input.args.filePath) {
        notes.push(await context("format-after-edit.sh", { tool_input: { file_path: input.args.filePath } }))
      }
      if (input.tool === "bash" && input.args.command) {
        const command = input.args.command
        notes.push(await context("package-manager-nudge.sh", { tool_input: { command } }))
        if (GIT_STAGE.test(command)) notes.push(await context("pre-tool-git-check.sh", { tool_input: { command } }))
      }
      for (const note of notes) if (note) output.output += `\n\n${note}`
    },

    "experimental.session.compacting": async (_input: unknown, output: CompactingOutput): Promise<void> => {
      const note = await context("precompact-state.sh", { trigger: "auto", cwd: directory })
      if (note) output.context.push(note)
    },
  }
}
