# justfile
# Developer commands

# Show available commands
default:
    @just --list

# Enter dev shell (if not using direnv)
shell:
    nix develop

# Update nixpkgs pin (may change tool patch versions)
update:
    nix flake update

# Check what would be built
check:
    nix flake check

# --- Project-specific recipes below ---

# build:
#     # project-specific build command

# test:
#     # project-specific test command

# lint:
#     # project-specific lint command
