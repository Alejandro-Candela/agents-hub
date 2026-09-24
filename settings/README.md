# settings/

Edit point for Claude Code's `settings.json` — hooks, permissions, env, plugins, status line.

`claude-settings.json` is the file you edit. It is **gitignored** and never leaves this machine: it holds a live context7 API key, a GitLab deploy token, an internal hostname, and absolute `/Users/...` paths. This repo is public.

```bash
./settings/sync-settings.sh          # push repo file -> ~/.claude/settings.json
./settings/sync-settings.sh pull     # capture live changes back into the repo file
./settings/sync-settings.sh diff     # show drift
```

Both directions back up the destination first (`*.bak-sync-<timestamp>`) and refuse to run on invalid JSON.

**Run `pull` after using `/config`, `/model`, `/permissions` or `/plugin`.** Claude Code writes those directly to the live file, so the repo copy goes stale and the next `push` would silently revert them.

Not a symlink: Claude Code rewrites `settings.json` itself, which would clobber one.

Hook *scripts* live in `hooks/` and are tracked. The wiring that invokes them lives here and is not — so a fresh machine needs a `push` before any hook actually fires.
