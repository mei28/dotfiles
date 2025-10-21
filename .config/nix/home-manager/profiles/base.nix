{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  # 基本的なCLIツールとユーティリティ
  home.packages = with pkgs; [
    # 基本ツール
    gh
    bat
    just

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

    # エディタ
    neovim

    # セッション管理
    tmux-mem-cpu-load

    # その他便利ツール
    tldr
    csvlens
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
    ../modules/zellij.nix
    ../modules/ssh.nix
  ];

  # Home Manager自身
  programs.home-manager.enable = true;

  # neovim設定は ~/.dotfiles/.config/nvim/ を直接使用（Lazy.nvim対応）
  # neovimパッケージは home.packages に含まれている（28行目）
  # .config/nvim を dotfiles からシンボリックリンク
  home.file.".config/nvim".source = ../../../nvim;

  # unfreeパッケージを許可
  nixpkgs.config.allowUnfree = true;
}
