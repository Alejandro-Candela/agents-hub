// OpenCode port of hooks/pre-push-public-check.sh. Delegates to the same bash
// script Claude Code runs, so the secret/domain patterns live in one place.
// The script speaks Claude Code's PreToolUse JSON; a "deny" becomes a thrown
// error, which is how an OpenCode plugin blocks a tool call.

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
  args: { command?: string }
}

interface Hooks {
  "tool.execute.before": (input: ToolInput, output: ToolOutput) => Promise<void>
}

const SCRIPT = join(homedir(), ".claude/hooks/pre-push-public-check.sh")
const GIT_PUSH = /(^|[;&|\s])git\s+push(\s|$)/

export const PrePushPublicCheck = async ({ $, directory }: PluginInput): Promise<Hooks> => ({
  "tool.execute.before": async (input: ToolInput, output: ToolOutput): Promise<void> => {
    const command = output.args.command ?? ""
    if (input.tool !== "bash" || !GIT_PUSH.test(command)) return

    const payload = new Response(JSON.stringify({ tool_input: { command } }))
    const result = await $`bash ${SCRIPT} < ${payload}`
      .cwd(directory)
      .env({ ...process.env, CLAUDE_PROJECT_DIR: directory })
      .quiet()
      .nothrow()
      .text()

    const reason: unknown = JSON.parse(result || "{}")?.hookSpecificOutput?.permissionDecisionReason
    if (typeof reason === "string") throw new Error(reason)
  },
})
