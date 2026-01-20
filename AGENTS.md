# Agent Instructions

## Development Environment

This project uses Nix flakes for reproducible development environments.

### Quick Reference

- **deps.toml** — Tool bundles and project-specific dependencies
- **flake.nix** — Nix shell definition (defines bundles, rarely needs editing)
- **flake.lock** — Pins exact versions (commit after `nix flake update`)

### Tool Bundles

Pre-defined tool collections available via `deps.toml`:

- `baseline` (28 tools) — Standalone CLI tools (no Python/Perl): ripgrep, fd, bat, fzf, jq, lazygit, etc.
- `complete` (58 tools) — Everything in baseline plus: tmux, gh, httpie, shellcheck, moreutils, etc.

### Adding a Dependency

1. Edit `deps.toml`:
   ```toml
   [bundles]
   include = ["baseline"]    # or "complete" or []

   [tools]
   newtool = "*"             # latest version
   python = "3.11"           # specific major.minor
   ```

2. If the tool needs version mapping (like python, nodejs), add to `versionMap` in flake.nix

3. Re-enter shell: `direnv reload` or `nix develop`

Note: Explicit `[tools]` take precedence over bundle tools in PATH.

### Commands

```bash
nix develop      # Enter dev shell
just shell       # Same as above
just update      # Update nixpkgs pin
```
