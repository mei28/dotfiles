{
  inputs,
  lib,
  pkgs,
  pkgsUnstable,
  system,
  ...
}:
let
  # 環境変数からユーザー名を取得（impureモード必須）
  runtimeUser = builtins.getEnv "USER";
  # フォールバック: 環境変数が空の場合は "user"
  username = if runtimeUser != "" then runtimeUser else "user";

  # OSに応じたホームディレクトリのルート
  homeRoot = if pkgs.stdenv.isDarwin then "/Users" else "/home";
in
{
  # base と development をインポート
  imports = [
    ./base.nix
    ./development.nix
  ];

  # ユーザー設定（動的に取得）
  home.username = username;
  home.homeDirectory = lib.mkDefault "${homeRoot}/${username}";

  # stateVersion
  home.stateVersion = "25.05";

  # リモート専用の追加設定
  programs.bash.bashrcExtra = lib.mkAfter ''
    # SSH接続時に自動tmux起動
    if [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
      # 既存のセッションにアタッチ、なければ新規作成
      tmux attach -t remote || tmux new-session -s remote
    fi
  '';

  # Git設定（リモート環境用）
  # 既存のmodules/git.nixがあるため、上書きが必要な場合のみ
  programs.git.settings = {
    user.name = lib.mkDefault username;
    user.email = lib.mkDefault "${username}@remote.local";
  };
}
