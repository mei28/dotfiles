#!/bin/bash
# Verification script to check if remote setup completed successfully
# This can be run after bootstrap or in Docker containers

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Dotfiles Setup Verification ==="
echo ""

# Check if Nix is installed
echo -n "Checking Nix installation... "
if command -v nix &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
    nix --version
else
    echo -e "${RED}✗ Nix not found${NC}"
    exit 1
fi

echo ""

# Source Nix environment if not already loaded
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# Check essential tools
echo "Checking essential tools:"

TOOLS=(
    "git"
    "gh"
    "tmux"
    "nvim"
    "fzf"
    "ripgrep"
    "fd"
    "bat"
    "zoxide"
)

FAILED=0

for tool in "${TOOLS[@]}"; do
    echo -n "  $tool... "
    if command -v "$tool" &> /dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        FAILED=$((FAILED + 1))
    fi
done

echo ""

# Check LSP servers
echo "Checking LSP servers:"

LSP_SERVERS=(
    "pyright"
    "gopls"
    "rust-analyzer"
)

for lsp in "${LSP_SERVERS[@]}"; do
    echo -n "  $lsp... "
    if command -v "$lsp" &> /dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}⚠${NC} (optional)"
    fi
done

echo ""

# Check home-manager state
echo -n "Checking home-manager state... "
if [ -e "$HOME/.local/state/nix/profiles/home-manager" ]; then
    echo -e "${GREEN}✓${NC}"
    echo "  Profile: $(readlink "$HOME/.local/state/nix/profiles/home-manager")"
else
    echo -e "${YELLOW}⚠ home-manager state not found${NC}"
fi

echo ""

# Check dotfiles directory
echo -n "Checking dotfiles directory... "
if [ -d "$HOME/.dotfiles" ]; then
    echo -e "${GREEN}✓${NC}"
    echo "  Location: $HOME/.dotfiles"
    echo "  Git branch: $(cd ~/.dotfiles && git branch --show-current 2>/dev/null || echo 'not a git repo')"
else
    echo -e "${YELLOW}⚠ ~/.dotfiles not found${NC}"
fi

echo ""

# Summary
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}=== All essential tools verified! ===${NC}"
    exit 0
else
    echo -e "${RED}=== $FAILED essential tools missing ===${NC}"
    exit 1
fi
