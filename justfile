# Shell setting: Use bash and enable strict error checking
set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# Define variables such as username
username := "mei"
darwinHost := "mei-darwin"

# -------------------------------------------------------
# 1) Task to update the flake only
# -------------------------------------------------------
update-flake:
  @echo "Updating flake..."
  nix flake update

# -------------------------------------------------------
# 2) Task to update Home Manager only
# -------------------------------------------------------
update-home:
  @echo "Updating Home Manager config..."
  nix run nixpkgs#home-manager -- switch --flake .#{{username}}

# -------------------------------------------------------
# 3) Task to update nix-darwin only
# -------------------------------------------------------
update-darwin:
  @echo "Updating nix-darwin config..."
  nix run nix-darwin -- switch --flake .#{{darwinHost}}

# -------------------------------------------------------
# 4) Update everything together (if needed)
# -------------------------------------------------------
# Specifying them as dependent tasks will run them in sequence
update-all: update-flake update-home update-darwin

# -------------------------------------------------------
# Default task (remove it if not needed)
# -------------------------------------------------------
default:
  @echo "Available tasks:"
  @echo "  just update-flake"
  @echo "  just update-home"
  @echo "  just update-darwin"
  @echo "  just update-all (runs all tasks in sequence)"

