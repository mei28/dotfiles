default: help

# List all available tasks
help:
  @echo "Available tasks:"
  just --list


# Shell setting: Use bash and enable strict error checking
set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# Define variables
dotfilesDir := env_var_or_default("DOTFILES_DIR", env_var("HOME") + "/dotfiles")

# ========================================
# Host-based Configuration
# ========================================
# Hosts: babalab-mac, sbi-mac, qia-aws, sbi-superpod

# Update flake.lock
update-flake:
  @echo "Updating flake..."
  nix flake update

# Apply Home Manager configuration for a host
update host:
  @echo "Updating Home Manager config for {{host}}..."
  home-manager switch --flake .#{{host}} --impure

# Bootstrap Home Manager (first-time setup)
bootstrap host:
  @echo "Bootstrapping Home Manager config for {{host}}..."
  nix run home-manager/master -- switch --flake .#{{host}} --impure

# Build Home Manager configuration without activating (for verification)
build host:
  @echo "Building Home Manager config for {{host}}..."
  home-manager build --flake .#{{host}} --impure

# Evaluate Home Manager configuration (fast syntax/reference check)
eval host:
  @echo "Evaluating Home Manager config for {{host}}..."
  nix eval --impure .#legacyPackages.aarch64-darwin.homeConfigurations.{{host}}.activationPackage

# Apply nix-darwin configuration for a host
update-darwin host:
  @echo "Updating nix-darwin config for {{host}}..."
  sudo darwin-rebuild switch --flake .#{{host}} --impure

# Bootstrap nix-darwin (first-time setup)
bootstrap-darwin host:
  @echo "Bootstrapping nix-darwin config for {{host}}..."
  sudo nix run nix-darwin -- switch --flake .#{{host}} --impure

# Update everything for a mac host (flake + home + darwin)
update-all host: update-flake (update host) (update-darwin host)

# Run garbage collection
gc:
  @echo "Garbage collecting..."
  nix store gc

# delete old Nix profiles and generations
delete-old-profiles:
  @echo "Deleting old Nix profiles and generations..."
  nix-collect-garbage -d


# ========================================
# Validation & Testing
# ========================================

# Check flake syntax and build all outputs
check:
  @echo "Checking flake..."
  nix flake check

# Format all Nix files
fmt:
  @echo "Formatting Nix files..."
  nix fmt

# Lint shell scripts (requires shellcheck)
lint-shell:
  @echo "Linting shell scripts..."
  shellcheck remote-bootstrap.sh setup.sh || echo "shellcheck not found, skipping..."

# Test remote setup in Docker (Ubuntu)
test-docker-ubuntu:
  @echo "Testing remote setup in Docker (Ubuntu)..."
  docker build -f test/Dockerfile.ubuntu -t dotfiles-test-ubuntu .
  docker run --rm -it dotfiles-test-ubuntu

# Test remote setup in Docker (Amazon Linux)
test-docker-amazon:
  @echo "Testing remote setup in Docker (Amazon Linux)..."
  docker build -f test/Dockerfile.amazonlinux -t dotfiles-test-amazon .
  docker run --rm -it dotfiles-test-amazon

# Run all tests
test-all: check lint-shell test-docker-ubuntu test-docker-amazon

# ========================================
# Utility
# ========================================

# Show current configuration info
info:
  @echo "=== Dotfiles Configuration Info ==="
  @echo "Runtime USER: $USER"
  @echo "Dotfiles Dir: {{dotfilesDir}}"
  @echo "System: $(uname -s)"
  @echo "Architecture: $(uname -m)"
  @echo ""
  @echo "Available hosts:"
  @echo "  babalab-mac   - Personal Mac (base + development + macos + darwin)"
  @echo "  sbi-mac       - Work Mac (base + development + macos + darwin)"
  @echo "  qia-aws       - AWS remote (base + development)"
  @echo "  sbi-superpod  - Superpod remote (base + development)"

# Clean up build artifacts
clean:
  @echo "Cleaning build artifacts..."
  rm -rf result result-*
  @echo "Done"
