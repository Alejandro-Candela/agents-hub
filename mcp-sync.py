import json
import os
import time

CLAUDE_CONFIG = os.path.expanduser("~/.claude/settings.json")
OPENCODE_CONFIG = os.path.expanduser("~/.opencode/opencode.json")
OPENCLAW_CONFIG = os.path.expanduser("~/.openclaw/openclaw.json")

def sync_mcps():
    if not os.path.exists(CLAUDE_CONFIG):
        return

    with open(CLAUDE_CONFIG, 'r') as f:
        claude_data = json.load(f)
    
    mcp_servers = claude_data.get('mcpServers', {})
    if not mcp_servers:
        return

    # Sync to OpenCode
    if os.path.exists(OPENCODE_CONFIG):
        with open(OPENCODE_CONFIG, 'r') as f:
            opencode_data = json.load(f)
        opencode_data['mcpServers'] = mcp_servers
        with open(OPENCODE_CONFIG, 'w') as f:
            json.dump(opencode_data, f, indent=2)
            print("✓ Synchronized MCPs to OpenCode")

    # Sync to OpenClaw
    if os.path.exists(OPENCLAW_CONFIG):
        with open(OPENCLAW_CONFIG, 'r') as f:
            openclaw_data = json.load(f)
        openclaw_data['mcpServers'] = mcp_servers
        with open(OPENCLAW_CONFIG, 'w') as f:
            json.dump(openclaw_data, f, indent=2)
            print("✓ Synchronized MCPs to OpenClaw")

if __name__ == "__main__":
    print("Starting Agent Sync (MCP loop)...")
    last_mtime = 0
    while True:
        try:
            current_mtime = os.path.getmtime(CLAUDE_CONFIG)
            if current_mtime > last_mtime:
                sync_mcps()
                last_mtime = current_mtime
        except Exception as e:
            print(f"Error: {e}")
        time.sleep(5)
