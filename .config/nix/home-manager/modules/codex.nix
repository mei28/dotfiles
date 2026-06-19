{ pkgs, config, ... }:
{
  # OpenAI Codex CLI（実装/レビュー担当）。Claude Code と併用する。
  # 運用ガイド: dotfiles/docs/claude-codex.md
  home.packages = [
    pkgs.codex
  ];

  # config.toml は symlink しない。codex が trust_level / UI フラグを実行時に書き込むため、
  # repo を汚さないよう codex 所有のままにする（~/.claude.json を管理しないのと同じ理由）。
  # 設定は codex 自身の TOML 安全なコマンドで行う（`codex mcp add` 等、justfile 参照）。
  home.file = {
    # AGENTS.md は Claude Code と共有（単一の真実）。codex はこのファイルに書き込まない。
    ".codex/AGENTS.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.claude/AGENTS.md";
    # Codex のカスタムプロンプト（slash commands）
    ".codex/prompts".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.codex/prompts";
  };
}
