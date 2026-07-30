{ pkgs, ... }:
{
  # Claude Code is installed by the native installer, not nix:
  #   ~/.local/bin/claude -> ~/.local/share/claude/versions/<version>
  # The native install self-updates (`claude update`); pkgs.claude-code cannot,
  # so it drifted behind (2.1.214 vs 2.1.220) while still sitting on PATH via
  # ~/.nix-profile/bin. Disabled to keep a single source of truth.
  # To hand Claude Code back to nix, uncomment the line below and drop the
  # native install (rm -rf ~/.local/bin/claude ~/.local/share/claude).
  home.packages = [
    # pkgs.claude-code
  ];
}
