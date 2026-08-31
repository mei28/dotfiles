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

  # statusline plugin の選択状態を XDG data 配下ではなく dotfiles 管理に寄せる。
  home.sessionVariables = {
    OPENCODE_STATUSLINE_CONFIG = "${config.home.homeDirectory}/dotfiles/.config/opencode/statusline-plugin.json";
  };

  # 設定ディレクトリを dotfiles に置く。認証情報は ~/.local/share/opencode/auth.json
  # に分離されるため、repo に秘密は入らない（codex の config.toml が symlink できない
  # のとは事情が違う）。
  #
  # この宣言はこのマシンでは実質 no-op になる。~/.config 自体が dotfiles/.config への
  # symlink なので、~/.config/opencode は最初から dotfiles の実体を指している。
  # 適用すると自己参照ループになるため home-manager は載せない。herdr の
  # xdg.configFile も同じ状態。~/.config が symlink でないホストのために残してある。
  #
  # opencode は config ディレクトリに書き込む。@opencode-ai/plugin を npm で入れるため
  # node_modules / package.json / package-lock.json が生える。opencode 自身が
  # .gitignore を置いてそれらを除外するので、repo は汚れない。
  # herdr と Clawd on Desk のインストーラも plugins/ に書き込む。そちらの生成物は
  # 追跡対象で、~/.claude/hooks/herdr-agent-state.sh と同じ扱い。
  xdg.configFile."opencode".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/opencode";
}
