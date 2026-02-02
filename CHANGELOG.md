# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- [NUR](https://github.com/nix-community/NUR) (Nix User Repository) integration
  - Add `[nur] include = ["mic92/hello-nur"]` to deps.toml
  - Access community packages not in nixpkgs
- [llm-agents.nix](https://github.com/numtide/llm-agents.nix) integration for AI coding agents
  - Add `[llm-agents] include = ["claude-code", "codex"]` to deps.toml
  - 60+ agents available: claude-code, codex, gemini-cli, amp, goose-cli, etc.
  - Packages auto-updated daily by numtide
- Charm Bracelet tools to complete bundle (61 tools total):
  - [gum](https://github.com/charmbracelet/gum) — shell script UI components
  - [vhs](https://github.com/charmbracelet/vhs) — terminal GIF recorder
  - [freeze](https://github.com/charmbracelet/freeze) — terminal screenshots
- Rust toolchain support via [rust-overlay](https://github.com/oxalica/rust-overlay)
  - Supports channels: `stable`, `beta`, `nightly`
  - Supports specific versions: `rust = "1.75.0"`
  - Configurable components via `rust-components` (default: rustfmt, clippy)
- Shell displays Rust version on entry when rust is configured

### Changed

- `flake.nix` now includes NUR as an input
- `flake.nix` now includes llm-agents.nix as an input
- `flake.nix` now includes rust-overlay as an input
- Updated deps.toml template with Rust examples
- Updated README with Rust documentation

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
