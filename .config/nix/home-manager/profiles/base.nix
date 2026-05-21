{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
{
  # 基本的なCLIツールとユーティリティ
  home.packages = with pkgs; [
    # 基本ツール
    gh
    bat
    just
    gnumake
    # intelli-shell

    # ファイル管理
    coreutils
    fd
    ripgrep
    tree
    wget
    curl
    zip
    unzip
    yazi
    trash-cli
    dust
    delta

    # エディタ
    neovim

    # セッション管理
    tmux-mem-cpu-load

    # その他便利ツール
    tldr
    csvlens
    mcat
    miniserve
    serie
  ];

  # 共通モジュールのインポート
  imports = [
    ../modules/bash.nix
    ../modules/git.nix
    ../modules/gitui.nix
    ../modules/fzf.nix
    ../modules/tmux.nix
    ../modules/fastfetch.nix
    ../modules/zoxide.nix
    ../modules/jujutsu.nix
    # ../modules/zellij.nix
    ../modules/ssh.nix
    ../modules/deno-pin.nix
  ];

  # Home Manager自身
  programs.home-manager.enable = true;

  # ~/.config -> ~/dotfiles/.config の大本 symlink を nix で自動作成する。
  # 既に存在する端末では何もしない (冪等)。これにより全端末で大本 symlink ベース運用に統一。
  home.activation.linkDotConfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    if [ ! -e "$HOME/.config" ] && [ ! -L "$HOME/.config" ]; then
      $DRY_RUN_CMD /bin/ln -s "$HOME/dotfiles/.config" "$HOME/.config"
    fi
  '';

  # ~/.config 配下以外の dotfile
  home.file = {
    ".claude".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.claude";
  };

  # unfreeパッケージを許可
  nixpkgs.config.allowUnfree = true;
}
