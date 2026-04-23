import json
import os
import time

# Paths
HUB_DIR = os.path.expanduser("~/agents-hub")
MASTER_CONFIG = os.path.join(HUB_DIR, "master-config.json")
GLOBAL_INSTRUCTIONS = os.path.join(HUB_DIR, "global-instructions.md")

CLAUDE_CONFIG = os.path.expanduser("~/.claude/settings.json")
CLAUDE_BAK = os.path.expanduser("~/.claude/settings.json.bak")
OPENCODE_CONFIG = os.path.expanduser("~/.opencode/opencode.json")
OPENCLAW_CONFIG = os.path.expanduser("~/.openclaw/openclaw.json")
OPENCLAW_AGENTS_MD = os.path.expanduser("~/.openclaw/workspace/AGENTS.md")
ANTIGRAVITY_CONFIG = os.path.expanduser("~/.gemini/antigravity/mcp_config.json")

# Binary Paths
NODE_BIN = "/Users/ALEX/.nvm/versions/node/v24.14.1/bin"
UV_BIN = "/Users/ALEX/.local/bin"
SYSTEM_PATHS = "/usr/bin:/bin:/usr/local/bin:/opt/homebrew/bin"
FULL_PATH = f"{NODE_BIN}:{UV_BIN}:{SYSTEM_PATHS}"

def update_global_instructions(master):
    persona = master.get("persona", "caveman-lite")
    auto_rtk = master.get("auto_rtk", True)
    
    rtk_mandate = ""
    if auto_rtk:
        rtk_mandate = """
## Orientation Protocol
- AT SESSION START: Proactively orientation in the project.
- Check `rtk status`, read `handoff.md` and `README.md` immediately. 
- Do not wait for user input to gather context.
"""

    content = f"""# Global Agent Hub - Master Instructions

## Agent Persona: {persona.upper()}
- ACTIVE EVERY RESPONSE. 
- Intensity: LITE.
- No filler/hedging. Keep articles + full sentences. Professional but tight.
- Drop "I", "me", "happy to help". Be direct.
- Technical accuracy is paramount.
{rtk_mandate}
## Tooling & Conventions
- **Python**: Use `uv` exclusively. (Avoid `pip`).
- **Node.js**: Use `bun` exclusively. (Avoid `npm`).
- **Git**: Automated reports on status and branch activity. Do not auto-init.

## Security & Safeguards
- **Sensitive Files**: Block edits or reads to `.env`, `credentials`, `key.json`, `*.pem` without explicit re-confirmation.
- **Tool Validation**: Check command syntax for dangerous side effects before execution.
"""
    with open(GLOBAL_INSTRUCTIONS, 'w') as f:
        f.write(content)

def transform_for_opencode(mcp_servers):
    return {
        name: {
            "type": "local",
            "command": [config["command"]] + config.get("args", []),
            "enabled": True
        }
        for name, config in mcp_servers.items()
    }

def transform_for_antigravity(mcp_servers):
    transformed = {}
    for name, config in mcp_servers.items():
        cmd = config["command"]
        args = config.get("args", [])
        cmd_path = f"{NODE_BIN}/npx" if cmd == "npx" else (f"{UV_BIN}/uvx" if cmd == "uvx" else cmd)
        args_escaped = " ".join([f"'{a}'" for a in args])
        wrapper_cmd = f"export PATH='{FULL_PATH}':$PATH; exec '{cmd_path}' {args_escaped}"
        transformed[name] = {"command": "sh", "args": ["-c", wrapper_cmd], "timeout": 60}
    return transformed

def sync_all():
    if not os.path.exists(MASTER_CONFIG): return
    with open(MASTER_CONFIG, 'r') as f:
        master = json.load(f)
    
    # 0. Update Global Instructions
    update_global_instructions(master)

    # 1. Source MCPs from Claude (or backup)
    target_config = CLAUDE_CONFIG if os.path.exists(CLAUDE_CONFIG) else CLAUDE_BAK
    if os.path.exists(target_config):
        with open(target_config, 'r') as f:
            claude_data = json.load(f)
        mcp_servers = claude_data.get('mcpServers', {})
        
        # Sync to OpenCode (Model + MCP)
        if os.path.exists(OPENCODE_CONFIG):
            with open(OPENCODE_CONFIG, 'r') as f:
                data = json.load(f)
            data['mcp'] = transform_for_opencode(mcp_servers)
            data['agent'] = data.get('agent', {})
            data['agent']['default'] = data['agent'].get('default', {})
            data['agent']['default']['model'] = master.get('default_model')
            with open(OPENCODE_CONFIG, 'w') as f:
                json.dump(data, f, indent=2)
        
        # Sync to Antigravity (MCP)
        data = {"mcpServers": transform_for_antigravity(mcp_servers)}
        with open(ANTIGRAVITY_CONFIG, 'w') as f:
            json.dump(data, f, indent=2)

    # 2. OpenClaw Symmetry
    if os.path.exists(OPENCLAW_AGENTS_MD):
        os.system(f"ln -sf {GLOBAL_INSTRUCTIONS} {OPENCLAW_AGENTS_MD}")

if __name__ == "__main__":
    print("Agent Hub Master Orchestrator Active...", flush=True)
    last_mtime_config = 0
    last_mtime_claude = 0
    while True:
        try:
            m1 = os.path.getmtime(MASTER_CONFIG)
            source_claude = CLAUDE_CONFIG if os.path.exists(CLAUDE_CONFIG) else CLAUDE_BAK
            m2 = os.path.getmtime(source_claude)
            if m1 > last_mtime_config or m2 > last_mtime_claude:
                sync_all()
                last_mtime_config, last_mtime_claude = m1, m2
        except Exception: pass
        time.sleep(5)
