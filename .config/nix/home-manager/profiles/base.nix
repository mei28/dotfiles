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
    ../modules/ssh.nix
    ../modules/deno-pin.nix
  ];

  # Home Manager自身
  programs.home-manager.enable = true;

  home.file = {
    ".config/nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/nvim";
    ".config/nix/home-manager/modules/configs".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/nix/home-manager/modules/configs";
    ".claude".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.claude";
  };

  # herdr: symlink config.toml only (sessions/ is runtime state, don't symlink the whole dir)
  xdg.configFile."herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/herdr/config.toml";

  # unfreeパッケージを許可
  nixpkgs.config.allowUnfree = true;
}
