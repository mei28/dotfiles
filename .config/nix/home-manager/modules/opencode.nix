{ pkgs, config, ... }:
{
  # opencode（Claude Code が使えないときのフォールバック主軸）。
  # GLM / Kimi を自前のローカルサーバで回す。運用ガイド: dotfiles/docs/opencode.md
  #
  # autoupdate は opencode.json で false にしてある。nix store は読み取り専用で、
  # 自己更新が走ると失敗するため。更新は `nix flake update` → `just update <host>`。
  home.packages = [
    pkgs.opencode
  ];

  # 設定ディレクトリは丸ごと symlink する。認証情報は ~/.local/share/opencode/auth.json
  # に分離されるため、丸ごと貼っても repo に秘密が入らない（codex の config.toml が
  # symlink できないのとは事情が違う）。
  # herdr と Clawd on Desk のインストーラが plugins/ に書き込むので、その生成物も
  # repo に入る。~/.claude/hooks/herdr-agent-state.sh と同じ扱い。
  xdg.configFile."opencode".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/opencode";
}
