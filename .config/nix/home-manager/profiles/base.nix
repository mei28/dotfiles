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

  # ~/.config は手動 symlink (~/.config -> ~/dotfiles/.config) で一括管理しているため、
  # その配下は home-manager で個別宣言しない。~/.config 配下以外のみここで管理する。
  home.file = {
    ".claude".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.claude";
  };

  # unfreeパッケージを許可
  nixpkgs.config.allowUnfree = true;
}
