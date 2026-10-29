import { describe, expect, test, beforeAll, afterAll } from "bun:test";
import { mkdtempSync, rmSync, readFileSync, readdirSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const REPO = join(import.meta.dir, "..");
let tempConfigDir: string;

beforeAll(() => {
  tempConfigDir = mkdtempSync(join(tmpdir(), "agy-test-"));
});

afterAll(() => {
  if (tempConfigDir && existsSync(tempConfigDir)) {
    rmSync(tempConfigDir, { recursive: true, force: true });
  }
});

describe("repo frontmatter validity", () => {
  test("every skill, agent, command, and rule has valid YAML frontmatter", () => {
    for (const kind of ["skills", "agents", "commands", "rules"] as const) {
      const base = join(REPO, kind);
      for (const entry of readdirSync(base).sort()) {
        const p = kind === "skills" ? join(base, entry, "SKILL.md") : join(base, entry);
        if (!p.endsWith(".md") || !existsSync(p)) continue;
        const txt = readFileSync(p, "utf8").replace(/\r\n/g, "\n");
        const m = txt.match(/^---\n([\s\S]*?)\n---/);
        expect(m).not.toBeNull();
        expect(() => Bun.YAML.parse(m![1])).not.toThrow();
      }
    }
  });
});

describe("sync-antigravity.sh", () => {
  test("generates agents, rules, command-skills, skills.json, and hooks.json", () => {
    const proc = Bun.spawnSync(["/bin/bash", join(REPO, "antigravity/sync-antigravity.sh")], {
      env: { ...process.env, AGY_CONFIG_DIR: tempConfigDir },
    });
    expect(proc.exitCode).toBe(0);

    // 1. Agents
    const adviserPath = join(tempConfigDir, "agents/adviser.md");
    expect(existsSync(adviserPath)).toBe(true);
    const adviserTxt = readFileSync(adviserPath, "utf8");
    const adviserFm = Bun.YAML.parse(adviserTxt.match(/^---\n([\s\S]*?)\n---/)![1]) as Record<string, unknown>;
    expect(adviserFm.enable_write_tools).toBe(false);
    expect(adviserFm.tools).toEqual(["view_file"]);

    const explorerTxt = readFileSync(join(tempConfigDir, "agents/explorer.md"), "utf8");
    const explorerFm = Bun.YAML.parse(explorerTxt.match(/^---\n([\s\S]*?)\n---/)![1]) as Record<string, unknown>;
    expect(explorerFm.enable_write_tools).toBe(true);
    expect(explorerFm.tools).toEqual(["view_file", "write_to_file"]);

    const resolverTxt = readFileSync(join(tempConfigDir, "agents/build-error-resolver.md"), "utf8");
    const resolverFm = Bun.YAML.parse(resolverTxt.match(/^---\n([\s\S]*?)\n---/)![1]) as Record<string, unknown>;
    expect(resolverFm.enable_write_tools).toBe(true);
    expect(resolverFm.tools).toEqual(["view_file", "write_to_file", "replace_file_content", "run_command"]);

    // 2. Rules
    const pyRulePath = join(tempConfigDir, "rules/python.md");
    expect(existsSync(pyRulePath)).toBe(true);
    const pyRuleFm = Bun.YAML.parse(readFileSync(pyRulePath, "utf8").match(/^---\n([\s\S]*?)\n---/)![1]) as Record<string, unknown>;
    expect(pyRuleFm.trigger).toBe("glob");
    expect(pyRuleFm.globs).toBe("**/*.py, **/*.pyi");

    const tsRulePath = join(tempConfigDir, "rules/typescript.md");
    expect(existsSync(tsRulePath)).toBe(true);
    const tsRuleFm = Bun.YAML.parse(readFileSync(tsRulePath, "utf8").match(/^---\n([\s\S]*?)\n---/)![1]) as Record<string, unknown>;
    expect(tsRuleFm.trigger).toBe("glob");
    expect(tsRuleFm.globs).toBe("**/*.ts, **/*.tsx, **/*.js, **/*.jsx");

    // 3. Commands -> command-skills + skills.json
    const primerSkillPath = join(tempConfigDir, "command-skills/primer/SKILL.md");
    expect(existsSync(primerSkillPath)).toBe(true);
    const primerFm = Bun.YAML.parse(readFileSync(primerSkillPath, "utf8").match(/^---\n([\s\S]*?)\n---/)![1]) as Record<string, unknown>;
    expect(primerFm.name).toBe("primer");
    expect(primerFm["disable-model-invocation"]).toBe(true);

    const skillsJsonPath = join(tempConfigDir, "skills.json");
    expect(existsSync(skillsJsonPath)).toBe(true);
    const skillsJson = JSON.parse(readFileSync(skillsJsonPath, "utf8"));
    expect(skillsJson.entries).toEqual([{ path: "~/.gemini/config/command-skills" }]);

    // 4. Hooks
    const hooksJsonPath = join(tempConfigDir, "hooks.json");
    expect(existsSync(hooksJsonPath)).toBe(true);
    const hooksJson = JSON.parse(readFileSync(hooksJsonPath, "utf8"));
    expect(hooksJson["agents-hub-guards"]).toBeDefined();
  });
});

describe("hooks-adapter.sh", () => {
  const adapter = join(REPO, "antigravity/hooks-adapter.sh");
  const runAdapter = (event: string, payload: object) => {
    const proc = Bun.spawnSync(["/bin/bash", adapter, event], {
      stdin: Buffer.from(JSON.stringify(payload)),
      env: process.env,
    });
    expect(proc.exitCode).toBe(0);
    return JSON.parse(proc.stdout.toString());
  };

  test("denies writing to sensitive files (.env)", () => {
    const json = runAdapter("PreToolUse", {
      toolCall: { name: "write_to_file", args: { TargetFile: "/tmp/project/.env" } },
      workspacePaths: [REPO],
    });
    expect(json.decision).toBe("deny");
    expect(json.reason).toContain(".env");
  });

  test("denies writing to sensitive files via write_file and edit_file with Path", () => {
    const jsonWrite = runAdapter("PreToolUse", {
      toolCall: { name: "write_file", args: { Path: "/tmp/project/.env" } },
      workspacePaths: [REPO],
    });
    expect(jsonWrite.decision).toBe("deny");
    expect(jsonWrite.reason).toContain(".env");

    const jsonEdit = runAdapter("PreToolUse", {
      toolCall: { name: "edit_file", args: { Path: "/tmp/project/credentials.json" } },
      workspacePaths: [REPO],
    });
    expect(jsonEdit.decision).toBe("deny");
    expect(jsonEdit.reason).toContain("credentials.json");
  });

  test("allows writing to normal files", () => {
    const json = runAdapter("PreToolUse", {
      toolCall: { name: "write_to_file", args: { TargetFile: "/tmp/project/index.ts" } },
      workspacePaths: [REPO],
    });
    expect(json.decision).toBe("allow");
  });

  test("allows benign run_command", () => {
    const json = runAdapter("PreToolUse", {
      toolCall: { name: "run_command", args: { CommandLine: "git status", Cwd: REPO } },
      workspacePaths: [REPO],
    });
    expect(json.decision).toBe("allow");
  });

  test("prompts with warning on pip install or npm install (package-manager-nudge)", () => {
    const json = runAdapter("PreToolUse", {
      toolCall: { name: "run_command", args: { CommandLine: "pip install requests", Cwd: REPO } },
      workspacePaths: [REPO],
    });
    expect(json.decision).toBe("ask");
    expect(json.reason).toContain("Use uv instead of pip");
  });

  test("denies git push when unpushed commit contains a secret", () => {
    const bareDir = mkdtempSync(join(tmpdir(), "agy-bare-"));
    const workDir = mkdtempSync(join(tmpdir(), "agy-work-"));
    try {
      Bun.spawnSync(["git", "init", "--bare", bareDir]);
      Bun.spawnSync(["git", "init", workDir]);
      Bun.spawnSync(["git", "-C", workDir, "config", "user.email", "test@example.com"]);
      Bun.spawnSync(["git", "-C", workDir, "config", "user.name", "Test"]);
      Bun.spawnSync(["git", "-C", workDir, "remote", "add", "origin", "https://github.com/octocat/Hello-World.git"]);
      Bun.write(join(workDir, "leaked.txt"), "aws_key=AKIA0123456789ABCDEF\n");
      Bun.spawnSync(["git", "-C", workDir, "add", "leaked.txt"]);
      Bun.spawnSync(["git", "-C", workDir, "commit", "-m", "initial"]);

      const json = runAdapter("PreToolUse", {
        toolCall: { name: "run_command", args: { CommandLine: "git push origin main", Cwd: workDir } },
        workspacePaths: [workDir],
      });
      expect(json.decision).toBe("deny");
      expect(json.reason).toContain("AKIA0123456789ABCDEF");
    } finally {
      rmSync(bareDir, { recursive: true, force: true });
      rmSync(workDir, { recursive: true, force: true });
    }
  });

  test("returns empty JSON object on PostToolUse", () => {
    const json = runAdapter("PostToolUse", {
      toolCall: { name: "write_to_file", args: { TargetFile: "/tmp/nonexistent.py" } },
      workspacePaths: [REPO],
    });
    expect(json).toEqual({});
  });
});
