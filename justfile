default: help

# List all available tasks
help:
  @echo "Available tasks:"
  just --list


# Shell setting: Use bash and enable strict error checking
set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# Define variables
username := "mei"
darwinHost := "mei-darwin"
dotfilesDir := env_var_or_default("DOTFILES_DIR", env_var("HOME") + "/.dotfiles")

# ========================================
# Local Environment (macOS)
# ========================================

# Update flake.lock
update-flake:
  @echo "Updating flake..."
  nix flake update

# Apply Home Manager configuration (macOS)
update-home:
  @echo "Updating Home Manager config (macOS)..."
  nix run nixpkgs#home-manager -- switch --flake .#{{username}}

# Apply nix-darwin configuration
update-darwin:
  @echo "Updating nix-darwin config..."
  nix run nix-darwin -- switch --flake .#{{darwinHost}}

# Update everything (flake + home + darwin)
update-all: update-flake update-home update-darwin

# Run garbage collection
gc:
  @echo "Garbage collecting..."
  nix store gc

# ========================================
# Remote Environment (EC2/Linux)
# ========================================

# Apply Home Manager configuration (Remote)
remote-apply:
  @echo "Applying Home Manager config (Remote)..."
  nix run home-manager/master -- switch --flake .#{{username}}-remote --impure

# Update and apply remote configuration
remote-update: update-flake remote-apply

# Test remote configuration build (dry-run)
remote-test:
  @echo "Testing remote configuration build..."
  nix build .#legacyPackages.$(nix eval --impure --raw --expr 'builtins.currentSystem').homeConfigurations.{{username}}-remote.activationPackage --dry-run

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
  @echo "Username: {{username}}"
  @echo "Darwin Host: {{darwinHost}}"
  @echo "Dotfiles Dir: {{dotfilesDir}}"
  @echo "System: $(uname -s)"
  @echo "Architecture: $(uname -m)"
  @echo ""
  @echo "Available profiles:"
  @nix flake show 2>/dev/null | grep homeConfigurations || echo "  Run 'nix flake show' for details"

# Clean up build artifacts
clean:
  @echo "Cleaning build artifacts..."
  rm -rf result result-*
  @echo "Done"
