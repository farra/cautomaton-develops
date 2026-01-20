# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [0.1.0] - 2026-01-20

### Added

- Initial release
- `deps.toml` format for declaring project dependencies
- `flake.nix` template that reads deps.toml and maps tools to nixpkgs
- Version mapping for Python, Node.js, Go, and Rust
- Tool bundles system:
  - `baseline` bundle: 28 standalone CLI tools (no Python/Perl runtimes)
  - `complete` bundle: 58 tools (baseline + tools that may pull runtimes)
- PATH precedence: explicit tools in `[tools]` override bundle tools
- Linux-specific libstdc++ inclusion for Python native extensions
- `justfile` with commands: `shell`, `update`, `upgrade`, `check`
- `.envrc` template with Pulumi ESC integration for secrets
- `AGENTS.md` template for AI agent instructions
- `.gitignore` with Nix-specific entries
- Two installation methods:
  - `nix flake init -t github:farra/cautomaton-develops`
  - `curl | bash` init script with smart merge/append, preflight checks, `-f/--force` and `-h/--help` flags
- Comprehensive README with:
  - Tool bundle tables with links
  - Version locking explanation
  - direnv/nix-direnv setup guide
  - deps.toml reference
  - Shell prompt integration tips
  - Related Projects section (compatible with [dev-agent-backlog](https://github.com/farra/dev-agent-backlog))
