// OpenCode port of hooks/sensitive-file-guard.sh. Delegates to the same bash
// script Claude Code runs, so the sensitive-path pattern lives in one place.
// A "deny" from the script becomes a thrown error, which blocks the tool call.

import { homedir } from "node:os"
import { join } from "node:path"

type Shell = typeof import("bun").$

interface PluginInput {
  $: Shell
  directory: string
}

interface ToolInput {
  tool: string
}

interface ToolOutput {
  args: { filePath?: string }
}

interface Hooks {
  "tool.execute.before": (input: ToolInput, output: ToolOutput) => Promise<void>
}

const SCRIPT = join(homedir(), ".claude/hooks/sensitive-file-guard.sh")
const WRITE_TOOLS = new Set(["write", "edit"])

export const SensitiveFileGuard = async ({ $, directory }: PluginInput): Promise<Hooks> => ({
  "tool.execute.before": async (input: ToolInput, output: ToolOutput): Promise<void> => {
    const filePath = output.args.filePath ?? ""
    if (!WRITE_TOOLS.has(input.tool) || !filePath) return

    const payload = new Response(JSON.stringify({ tool_input: { file_path: filePath } }))
    const result = await $`bash ${SCRIPT} < ${payload}`.cwd(directory).quiet().nothrow().text()

    const reason: unknown = JSON.parse(result || "{}")?.hookSpecificOutput?.permissionDecisionReason
    if (typeof reason === "string") throw new Error(reason)
  },
})
