# cautomaton-develops

A project template for reproducible development environments using Nix flakes.

This template is an opinionated thin layer. Very thin. You don't need this. Just have Claude or Codex write it for you.

What is it?

- nix (primary `nix develop`)
- just

Optional but encouraged:

- direnv
- Pulumi ESC (yeah, that one might surprise you, but I use it for secrets management, it's fantastic)

This template merely provides a default `flake.nix` that reads a local `deps.toml` that declares project dependencies. A default `justfile` is included too. I told you it was thin. The flake does include some "bundles" for common tools that _should_ be in your path but might not be (i.e. `jq`). 

## Goals

- Keep your system clean.
- Keep project dependencies with the projects.
- Make it easy to know what a project needs and expects.
- As little magic as possible. 

## Non-Goals

- Dev containers
- Distroboxes

That said, this setup makes initializing your devcontainer extremely simple.

---

## Installation

**Prerequisites:** [Nix](https://nixos.org/download.html) with flakes enabled

### Option 1: nix flake init (recommended)

```bash
cd myproject
nix flake init -t github:farra/cautomaton-develops
```

Clean, native to Nix. Copies template files to current directory.

### Option 2: init script (smart, handles existing projects)

```bash
# Run in current directory
curl -sL https://raw.githubusercontent.com/farra/cautomaton-develops/main/init.sh | bash

# Or specify a target directory
curl -sL https://raw.githubusercontent.com/farra/cautomaton-develops/main/init.sh | bash -s -- ~/dev/myproject

# Force mode (skip confirmation prompts)
curl -sL https://raw.githubusercontent.com/farra/cautomaton-develops/main/init.sh | bash -s -- -f .
```

The script will:
- Show what will be created before proceeding
- Prompt for confirmation if directory has existing files
- Skip files that already exist (won't overwrite)
- Merge new entries into existing `.gitignore`
- Append to existing `AGENTS.md` if present

Options: `-f/--force` (skip prompts), `-h/--help` (show usage)

### After installation

```bash
# Edit deps.toml to add your dependencies
# Then enter the development shell
nix develop

# Or use just
just shell
```

That's it. All tools declared in `deps.toml` are now available.

---

## Commands

```bash
just              # List available commands
just shell        # Enter dev shell (if not using direnv)
just update       # Update nixpkgs pin (may bump tool versions)
just upgrade      # Upgrade flake.nix to latest template (shows diff, asks to confirm)
just check        # Validate flake
```

---

## Adding Dependencies

Edit `deps.toml`:

```toml
[bundles]
include = ["baseline"]    # Pre-built tool collections (optional)

[tools]
rust = "stable"           # "stable", "beta", "nightly", or "1.75.0"
python = "3.12"           # Nix provides interpreter; use uv for packages
nodejs = "20"
uv = true                 # Fast Python package manager
mytool = true             # Latest in nixpkgs

# Rust components (default: rustfmt, clippy)
rust-components = ["rustfmt", "clippy", "rust-src", "rust-analyzer"]
```

Then re-enter the shell: `exit` and `nix develop` (or `direnv reload` if using direnv).

---

## Tool Bundles

Pre-defined collections of commonly useful tools. Include them via `deps.toml`:

```toml
[bundles]
include = ["baseline"]   # or ["complete"] or []
```

| Bundle     | Tools | Description                                     |
|------------|-------|-------------------------------------------------|
| `baseline` | 28    | Standalone CLI tools — no Python/Perl runtimes  |
| `complete` | 58    | Comprehensive dev environment (baseline + more) |

Explicit tools in `[tools]` always take precedence over bundle tools in PATH.

### baseline (28 tools)

Lightweight, standalone binaries (Rust/Go/C). No heavy language runtimes.

| Category | Tools |
|----------|-------|
| **Core Replacements** | [ripgrep](https://github.com/BurntSushi/ripgrep), [fd](https://github.com/sharkdp/fd), [bat](https://github.com/sharkdp/bat), [eza](https://github.com/eza-community/eza), [sd](https://github.com/chmln/sd), [dust](https://github.com/bootandy/dust), [duf](https://github.com/muesli/duf), [bottom](https://github.com/ClementTsang/bottom), [difftastic](https://github.com/Wilfred/difftastic) |
| **Navigation** | [zoxide](https://github.com/ajeetdsouza/zoxide), [fzf](https://github.com/junegunn/fzf), [broot](https://github.com/Canop/broot), [tree](https://linux.die.net/man/1/tree) |
| **Git** | [delta](https://github.com/dandavison/delta), [lazygit](https://github.com/jesseduffield/lazygit) |
| **Data Processing** | [jq](https://github.com/stedolan/jq), [yq-go](https://github.com/mikefarah/yq), [csvtk](https://github.com/shenwei356/csvtk), [htmlq](https://github.com/mgdm/htmlq), [miller](https://github.com/johnkerl/miller) |
| **Shell** | [atuin](https://github.com/atuinsh/atuin), [direnv](https://github.com/direnv/direnv), [just](https://github.com/casey/just) |
| **Utilities** | [tealdeer](https://github.com/dbrgn/tealdeer), [curlie](https://github.com/rs/curlie), [glow](https://github.com/charmbracelet/glow), [entr](https://github.com/eradman/entr), [pv](https://linux.die.net/man/1/pv) |

### complete (58 tools)

Everything in baseline, plus tools that may pull in language runtimes:

| Category | Additional Tools |
|----------|------------------|
| **Core Replacements** | [procs](https://github.com/dalance/procs), [choose](https://github.com/theryangeary/choose) |
| **Git & GitHub** | [gh](https://github.com/cli/cli), [git-extras](https://github.com/tj/git-extras), [tig](https://github.com/jonas/tig) |
| **Data Processing** | [fx](https://github.com/antonmedv/fx) |
| **Shell** | [shellcheck](https://github.com/koalaman/shellcheck), [starship](https://github.com/starship/starship) |
| **File Operations** | [rsync](https://rsync.samba.org/), [trash-cli](https://github.com/andreafrancia/trash-cli), [watchexec](https://github.com/watchexec/watchexec), [renameutils](https://www.nongnu.org/renameutils/) |
| **Networking** | [curl](https://curl.se/), [wget](https://www.gnu.org/software/wget/), [httpie](https://github.com/httpie/httpie) |
| **Archives** | [unzip](https://linux.die.net/man/1/unzip), [p7zip](https://github.com/p7zip-project/p7zip), [zstd](https://github.com/facebook/zstd) |
| **System** | [tmux](https://github.com/tmux/tmux), [watch](https://linux.die.net/man/1/watch), [less](https://www.greenwoodsoftware.com/less/), [file](https://linux.die.net/man/1/file), [lsof](https://linux.die.net/man/8/lsof), [moreutils](https://joeyh.name/code/moreutils/) |
| **Development** | [hyperfine](https://github.com/sharkdp/hyperfine), [tokei](https://github.com/XAMPPRocky/tokei), [navi](https://github.com/denisidoro/navi) |
| **Clipboard** | [xclip](https://github.com/astrand/xclip), [wl-clipboard](https://github.com/bugaevc/wl-clipboard) |
| **Logs** | [lnav](https://github.com/tstack/lnav) |

---

## Design Philosophy

### Minimal Substrate, Maximum Isolation

Keep your base system clean. Project-specific dependencies live in isolation via Nix.

- **System level**: Nix, just, git — universal, always available
- **Project level**: Languages, build tools, project CLIs — isolated, reproducible

### Edit TOML, Not Nix

`deps.toml` is the human/agent-friendly interface:

```toml
[tools]
python = "3.11"    # Maps to pkgs.python311
nodejs = "20"      # Maps to pkgs.nodejs_20
ripgrep = "*"      # Latest in nixpkgs
```

The `flake.nix` handles the Nix complexity. You rarely need to edit it.

### Layered Opt-In

| Level       | What You Use                           | What You Skip |
|-------------|----------------------------------------|---------------|
| **Full**    | direnv (auto-activates on `cd`)        | Nothing       |
| **Manual**  | `nix develop` or `just shell`          | direnv        |
| **Minimal** | Read `deps.toml`, install via brew/apt | Nix entirely  |

The architecture supports all three. `deps.toml` is readable by anyone.

### Agent-Friendly

AI coding agents can:
- Read `deps.toml` to understand project dependencies
- Help maintain `flake.nix` when complex changes are needed
- Add new tools or update version mappings

---

## Project Structure

```
myproject/
├── deps.toml        # Tool inventory (human/agent readable)
├── flake.nix        # Nix shell definition (boilerplate)
├── flake.lock       # Pins nixpkgs revision (auto-generated)
├── .envrc           # direnv config (optional)
├── justfile         # Developer commands
├── AGENTS.md        # AI agent instructions
└── ...
```

### File Responsibilities

| File         | Purpose                             | Edit Frequency                    |
|--------------|-------------------------------------|-----------------------------------|
| `deps.toml`  | Declare tools and bundles           | Often                             |
| `flake.nix`  | Map deps to nixpkgs, define bundles | Rarely                            |
| `flake.lock` | Pin exact versions                  | Auto (commit after `just update`) |
| `.envrc`     | Auto-activate shell, load secrets   | Once per project                  |
| `justfile`   | Developer-facing commands           | As needed                         |

---

## Version Locking

Two layers of version control:

| Layer           | Controls                       | File         |
|-----------------|--------------------------------|--------------|
| **Major/Minor** | Which Python: 3.11 vs 3.12     | `deps.toml`  |
| **Patch**       | Which 3.11.x: 3.11.8 vs 3.11.9 | `flake.lock` |

### How It Works

1. `deps.toml` says `python = "3.11"`
2. `flake.nix` maps this to `pkgs.python311`
3. `flake.lock` pins nixpkgs at a specific commit
4. That commit's python311 is version 3.11.x

### Updating

```bash
just update    # Update nixpkgs pin (may bump patch versions)
git add flake.lock && git commit -m "Update nixpkgs"
```

---

## direnv Integration (Optional)

For automatic shell activation when you `cd` into the project.

### Prerequisites

- [direnv](https://direnv.net/)
- [nix-direnv](https://github.com/nix-community/nix-direnv) (for caching — highly recommended)

### Setup

```bash
# Install nix-direnv
nix profile install nixpkgs#nix-direnv

# Add to ~/.config/direnv/direnvrc
echo 'source $HOME/.nix-profile/share/nix-direnv/direnvrc' >> ~/.config/direnv/direnvrc

# Allow this project
direnv allow
```

### Why nix-direnv?

Plain direnv with `use flake` re-evaluates on every shell prompt — slow.

nix-direnv provides:
- **Caching**: Shells load instantly after first build
- **GC roots**: `nix-collect-garbage` won't delete your env
- **Background rebuild**: Updates when `flake.nix` changes

---

## Shell Prompt Integration

When inside a `nix develop` shell, Nix sets `IN_NIX_SHELL=impure`. Prompt tools can use this to show an indicator.

**Starship** has built-in support via the [`nix_shell` module](https://starship.rs/config/#nix-shell).

**Oh-my-posh** can use a conditional segment:
```json
{ "template": "{{ if .Env.IN_NIX_SHELL }}❄️{{ end }}" }
```

---

## deps.toml Reference

### Rules

1. **Only dependencies** — no shell hooks, no conditionals
2. **Version = major.minor** — patch versions come from `flake.lock`
3. **`true` or `"*"` means latest** — whatever's in the pinned nixpkgs

### Format

```toml
# deps.toml

# Include pre-built tool bundles
[bundles]
include = ["baseline"]    # Options: "baseline", "complete", or []

# Project-specific tools
[tools]
rust = "stable"           # Via rust-overlay: "stable", "beta", "nightly", "1.75.0"
python = "3.12"           # Nix interpreter; use uv for package management
nodejs = "20"
go = "1.22"
uv = true                 # Fast Python package manager
pulumi = true             # Latest in nixpkgs

# Rust components (only when rust is specified)
rust-components = ["rustfmt", "clippy", "rust-src", "rust-analyzer"]
```

### What Does NOT Go Here

- Platform-specific dependencies → `flake.nix`
- Shell initialization → `.envrc`
- Secrets or environment variables → `.envrc` via [Pulumi ESC](https://www.pulumi.com/docs/esc/)
- Conditional logic

---

## Secrets Management

Keep secrets out of files. Use [Pulumi ESC](https://www.pulumi.com/docs/esc/) for environment-based secrets:

```bash
# .envrc
export PULUMI_ESC_ENV="myorg/dev"
use flake

if command -v pulumi &> /dev/null && [ -n "${PULUMI_ESC_ENV:-}" ]; then
  eval "$(pulumi env open "$PULUMI_ESC_ENV" --format shell 2>/dev/null || true)"
fi
```

Secrets exist only in memory, never committed to files.

Seriously, this is just magical. Use it.

---

## Extending the Version Map

Most tools use `true` and map directly to their nixpkgs name. For tools with version-specific naming (python, nodejs, go), the `flake.nix` has a `versionMap`:

```nix
versionMap = {
  python = {
    "3.11" = pkgs.python311;
    "3.12" = pkgs.python312;
  };
  nodejs = {
    "20" = pkgs.nodejs_20;
    "22" = pkgs.nodejs_22;
  };
};
```

**Rust** is handled specially via [rust-overlay](https://github.com/oxalica/rust-overlay), supporting channels (`stable`, `beta`, `nightly`) and specific versions (`1.75.0`). Components like `rustfmt`, `clippy`, and `rust-src` are configured via `rust-components`.

To add a new version mapping, edit `flake.nix` or ask an AI agent to help.

---

## Platform Support

Tested on:
- `x86_64-linux` (Linux, WSL)
- `aarch64-linux` (Linux ARM)
- `aarch64-darwin` (macOS Apple Silicon)
- `x86_64-darwin` (macOS Intel)

Linux builds automatically include `libstdc++` for Python native extensions (grpcio, etc.).

---

## References

- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [rust-overlay](https://github.com/oxalica/rust-overlay) — Rust toolchain management for Nix
- [nix-direnv](https://github.com/nix-community/nix-direnv)
- [Pulumi ESC](https://www.pulumi.com/docs/esc/)
- [Modern Unix Tools](https://github.com/ibraheemdev/modern-unix)

---

## Related Projects

**[dev-agent-backlog](https://github.com/farra/dev-agent-backlog)** — Org-mode based task management for human-agent collaboration. Provides backlog tracking, design documents (RFC/RFD style), and Claude Code commands/skills.

The two projects complement each other and can be overlaid on the same project:
- **cautomaton-develops**: Reproducible dev environment (Nix, tools, dependencies)
- **dev-agent-backlog**: Task/design management (backlog, design docs, agent workflows)

```bash
# Use both in the same project
curl -sL https://raw.githubusercontent.com/farra/cautomaton-develops/main/init.sh | bash
bash <(curl -sL https://raw.githubusercontent.com/farra/dev-agent-backlog/main/bin/init.sh) MYPREFIX .
```

---

## TODO

- [ ] **Troubleshooting section** — Common errors: "Unknown package", flakes not enabled, direnv not allowed
- [ ] **`just tools` recipe** — Print bundle contents from CLI instead of reading README
- [ ] **Versioning/releases** — Tag releases so users can pin: `nix flake init -t github:farra/cautomaton-develops/v1.0`
- [ ] **Example deps.toml snippets** — Python project, Node project, Rust project examples
- [ ] **FAQ: "How do I exclude a bundle tool?"** — Answer: don't use bundles, list tools explicitly

---

## License

Apache 2
