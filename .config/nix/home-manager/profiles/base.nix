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
    # git は modules/git.nix で programs.git.enable = true で管理
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
    # neovim は programs.neovim.plugins で管理

    # セッション管理
    # tmux は modules/tmux.nix で programs.tmux.enable = true で管理
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

  # neovim基本設定
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.sqlite-lua;
      config =
        let
          sqliteLib = if pkgs.stdenv.isDarwin then "libsqlite3.dylib" else "libsqlite3.so";
        in
        "vim.g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/${sqliteLib}'";
    }
  ];

  # unfreeパッケージを許可
  nixpkgs.config.allowUnfree = true;
}
