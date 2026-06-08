#!/bin/bash
# Bootstrap script for remote environments (EC2, etc.)
# Usage: curl -sSL https://raw.githubusercontent.com/mei28/dotfiles/main/remote-bootstrap.sh | bash -s -- <host>
# Example: curl -sSL ... | bash -s -- qia-aws

set -euo pipefail

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Host name is required
HOST="${1:-}"
if [ -z "$HOST" ]; then
  echo -e "${RED}Error: host name required${NC}"
  echo "Usage: $0 <host>"
  echo "Available hosts: qia-aws, sbi-superpod"
  exit 1
fi

echo -e "${GREEN}Starting remote development environment setup (host: ${HOST})...${NC}"
echo -e "${YELLOW}Current user: $(whoami)${NC}"
echo ""

# 1. Install Nix
if ! command -v nix &> /dev/null; then
  echo -e "${YELLOW}Installing Nix...${NC}"
  curl --proto '=https' --tlsv1.2 -sSf -L \
    https://install.determinate.systems/nix | sh -s -- install --no-confirm

  # Reload environment variables
  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi

  echo -e "${GREEN}Nix installation completed${NC}"
else
  echo -e "${GREEN}Nix is already installed${NC}"
fi

# 2. Clone dotfiles
DOTFILES_DIR="${HOME}/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
  echo -e "${YELLOW}Cloning dotfiles...${NC}"
  git clone --depth 1 https://github.com/mei28/dotfiles.git "$DOTFILES_DIR"
  echo -e "${GREEN}Dotfiles cloned successfully${NC}"
else
  echo -e "${GREEN}Dotfiles already exist${NC}"
  echo -e "${YELLOW}   To update: cd $DOTFILES_DIR && git pull${NC}"
fi

cd "$DOTFILES_DIR"

# 3. Apply home-manager configuration (impure mode for environment variables)
echo ""
echo -e "${YELLOW}Applying home-manager configuration (host: ${HOST}, user: $(whoami))...${NC}"
echo -e "${YELLOW}   This may take a few minutes${NC}"

nix run home-manager/master -- switch --flake ".#${HOST}" --impure

echo ""
echo -e "${GREEN}Setup completed successfully!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Reload shell: ${GREEN}exec bash${NC}"
echo "  2. Start tmux session: ${GREEN}tmux${NC}"
echo "  3. To update configuration: ${GREEN}cd ~/dotfiles && git pull && just update ${HOST}${NC}"
echo ""
echo -e "${YELLOW}Troubleshooting:${NC}"
echo "  - If nix is not found: Open a new shell session"
echo "  - For configuration issues: See ~/dotfiles/README.md"
echo ""
