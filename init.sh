#!/usr/bin/env bash
#
# Initialize a project with cautomaton-develops template
#
# Usage: curl -sL https://raw.githubusercontent.com/farra/cautomaton-develops/main/init.sh | bash
#        ./init.sh [options] [target-dir]
#
# Options:
#   -f, --force    Bypass safety checks (skip confirmation prompts)
#   -h, --help     Show this help message
#
# Example:
#   curl -sL https://raw.githubusercontent.com/farra/cautomaton-develops/main/init.sh | bash
#   ./init.sh ~/dev/myproject
#   ./init.sh -f .
#

set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/farra/cautomaton-develops/main/template"

usage() {
    if [[ -f "$0" ]]; then
        sed '/^#/!q' "$0" | grep '^#[^!]' | cut -c3-
    else
        cat << 'EOF'
Initialize a project with cautomaton-develops template

Usage: curl -sL https://raw.githubusercontent.com/farra/cautomaton-develops/main/init.sh | bash
       ./init.sh [options] [target-dir]

Options:
  -f, --force    Bypass safety checks (skip confirmation prompts)
  -h, --help     Show this help message

Example:
  curl -sL https://raw.githubusercontent.com/farra/cautomaton-develops/main/init.sh | bash
  ./init.sh ~/dev/myproject
  ./init.sh -f .
EOF
    fi
    exit "${1:-1}"
}

FORCE=false
TARGET="."

# Process arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage 0
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage 1
            ;;
        *)
            TARGET="$1"
            shift
            ;;
    esac
done

# Resolve target to absolute path (create if needed)
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

# Colors (if terminal supports them)
if [[ -t 1 ]]; then
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color
else
  GREEN=''
  YELLOW=''
  BLUE=''
  NC=''
fi

info() { echo -e "${BLUE}[info]${NC} $1"; }
warn() { echo -e "${YELLOW}[skip]${NC} $1"; }
success() { echo -e "${GREEN}[created]${NC} $1"; }

# Download a file, skip if exists
download_file() {
  local file="$1"
  local url="${REPO_URL}/${file}"

  if [[ -f "$file" ]]; then
    warn "$file already exists"
    return 0
  fi

  curl -sL "$url" -o "$file"
  success "$file"
}

# Merge .gitignore entries (add missing lines)
merge_gitignore() {
  local url="${REPO_URL}/.gitignore"
  local temp_file
  temp_file=$(mktemp)

  curl -sL "$url" -o "$temp_file"

  if [[ ! -f .gitignore ]]; then
    mv "$temp_file" .gitignore
    success ".gitignore"
    return 0
  fi

  # Add missing entries
  local added=0
  while IFS= read -r line; do
    # Skip empty lines and comments for matching
    if [[ -n "$line" ]] && ! grep -qxF "$line" .gitignore 2>/dev/null; then
      echo "$line" >> .gitignore
      ((added++)) || true
    fi
  done < "$temp_file"

  rm "$temp_file"

  if [[ $added -gt 0 ]]; then
    success ".gitignore (added $added entries)"
  else
    warn ".gitignore already up to date"
  fi
}

# Append AGENTS.md content if not already present
append_agents_md() {
  local url="${REPO_URL}/AGENTS.md"
  local temp_file
  temp_file=$(mktemp)

  curl -sL "$url" -o "$temp_file"

  if [[ ! -f AGENTS.md ]]; then
    mv "$temp_file" AGENTS.md
    success "AGENTS.md"
    return 0
  fi

  # Check if the dev environment section already exists
  if grep -q "## Development Environment" AGENTS.md 2>/dev/null; then
    rm "$temp_file"
    warn "AGENTS.md already has Development Environment section"
    return 0
  fi

  # Append with a separator
  echo "" >> AGENTS.md
  cat "$temp_file" >> AGENTS.md
  rm "$temp_file"
  success "AGENTS.md (appended Development Environment section)"
}

main() {
  echo ""
  echo "cautomaton-develops template"
  echo "============================"
  echo ""

  # Show what we're about to do
  info "Target directory: $TARGET"
  echo ""
  echo "This will create/update the following files:"
  echo "  - flake.nix      (Nix flake definition)"
  echo "  - deps.toml      (Tool dependencies)"
  echo "  - justfile       (Developer commands)"
  echo "  - .envrc         (direnv configuration)"
  echo "  - .gitignore     (merge new entries)"
  echo "  - AGENTS.md      (append if exists)"
  echo ""

  # Check for existing flake.nix (strong indicator of conflict)
  if [[ -f "$TARGET/flake.nix" ]]; then
    if ! $FORCE; then
      warn "flake.nix already exists in target directory"
      echo ""
      read -p "    Overwriting may break your existing Nix setup. Continue? [y/N] " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Initialization cancelled."
        exit 1
      fi
      echo ""
    fi
  # Check if target has other files (general warning)
  elif ! $FORCE && [ -n "$(ls -A "$TARGET" 2>/dev/null)" ]; then
    info "Target directory is not empty"
    read -p "    Continue with initialization? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Initialization cancelled."
      exit 1
    fi
    echo ""
  fi

  # Change to target directory for all operations
  cd "$TARGET"

  # Core files (skip if exist)
  download_file "flake.nix"
  download_file "deps.toml"
  download_file "justfile"
  download_file ".envrc"

  # Smart merge/append
  merge_gitignore
  append_agents_md

  echo ""
  info "Done! Next steps:"
  echo "  1. Edit deps.toml to add your dependencies"
  echo "  2. Run 'nix develop' or 'just shell'"
  echo "  3. If using direnv: 'direnv allow'"
  echo ""
}

main
