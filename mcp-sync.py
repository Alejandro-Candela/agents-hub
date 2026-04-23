import json
import os
import time

CLAUDE_CONFIG = os.path.expanduser("~/.claude/settings.json")
CLAUDE_BAK = os.path.expanduser("~/.claude/settings.json.bak")
OPENCODE_CONFIG = os.path.expanduser("~/.opencode/opencode.json")
OPENCLAW_CONFIG = os.path.expanduser("~/.openclaw/openclaw.json")
ANTIGRAVITY_CONFIG = os.path.expanduser("~/.gemini/antigravity/mcp_config.json")

# Core Tool Paths
NODE_BIN = "/Users/ALEX/.nvm/versions/node/v24.14.1/bin"
UV_BIN = "/Users/ALEX/.local/bin"
SYSTEM_PATHS = "/usr/bin:/bin:/usr/local/bin:/opt/homebrew/bin"
FULL_PATH = f"{NODE_BIN}:{UV_BIN}:{SYSTEM_PATHS}"

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
        
        # Resolve absolute binary for the wrapper
        if cmd == "npx":
            cmd_path = f"{NODE_BIN}/npx"
        elif cmd == "uvx":
            cmd_path = f"{UV_BIN}/uvx"
        else:
            cmd_path = cmd

        # We wrap in sh -c to ensure PATH is inherited by sub-processes (like npx spawning node)
        # We escape arguments to ensure they pass correctly to the inner shell
        args_escaped = " ".join([f"'{a}'" for a in args])
        wrapper_cmd = f"export PATH='{FULL_PATH}':$PATH; exec '{cmd_path}' {args_escaped}"
        
        transformed[name] = {
            "command": "sh",
            "args": ["-c", wrapper_cmd],
            "timeout": config.get("timeout", 60) # Increased timeout for initial npx/uvx runs
        }
    return transformed

def sync_mcps():
    target_config = CLAUDE_CONFIG if os.path.exists(CLAUDE_CONFIG) else CLAUDE_BAK
    if not os.path.exists(target_config):
        return

    try:
        with open(target_config, 'r') as f:
            claude_data = json.load(f)
    except Exception as e:
        print(f"Error reading Claude config: {e}")
        return
    
    mcp_servers = claude_data.get('mcpServers', {})
    if not mcp_servers:
        return

    # 1. OpenCode
    if os.path.exists(OPENCODE_CONFIG):
        try:
            with open(OPENCODE_CONFIG, 'r') as f:
                data = json.load(f)
            data['mcp'] = transform_for_opencode(mcp_servers)
            data.pop('mcpServers', None) 
            with open(OPENCODE_CONFIG, 'w') as f:
                json.dump(data, f, indent=2)
            print("✓ Sync: OpenCode", flush=True)
        except Exception as e:
            print(f"Error OpenCode: {e}")

    # 2. OpenClaw
    if os.path.exists(OPENCLAW_CONFIG):
        try:
            with open(OPENCLAW_CONFIG, 'r') as f:
                data = json.load(f)
            data['mcpServers'] = mcp_servers
            with open(OPENCLAW_CONFIG, 'w') as f:
                json.dump(data, f, indent=2)
            print("✓ Sync: OpenClaw", flush=True)
        except Exception as e:
            print(f"Error OpenClaw: {e}")

    # 3. Antigravity (with PATH wrapper)
    try:
        data = {"mcpServers": transform_for_antigravity(mcp_servers)}
        with open(ANTIGRAVITY_CONFIG, 'w') as f:
            json.dump(data, f, indent=2)
        print("✓ Sync: Antigravity (PATH Wrapper Active)", flush=True)
    except Exception as e:
        print(f"Error Antigravity: {e}")

if __name__ == "__main__":
    print("Agent Sync Hub Active (Instructions + MCP + Secure Wrappers)...", flush=True)
    last_mtime = 0
    while True:
        try:
            source = CLAUDE_CONFIG if os.path.exists(CLAUDE_CONFIG) else CLAUDE_BAK
            current_mtime = os.path.getmtime(source)
            if current_mtime > last_mtime:
                sync_mcps()
                last_mtime = current_mtime
        except Exception as e:
            pass
        time.sleep(5)
