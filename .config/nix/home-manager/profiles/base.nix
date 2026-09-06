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

  # Every ~/.config entry is declared per app rather than covered by a single
  # ~/.config -> ~/dotfiles/.config symlink. Hosts that still have that symlink
  # skip these as no-ops; hosts without it reach the config only through here.
  # Declaring each one keeps the managed set readable and the hosts in sync.
  home.file = {
    ".config/nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/nvim";
    ".config/nix/home-manager/modules/configs".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/nix/home-manager/modules/configs";
    ".claude".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.claude";
  };

  # herdr: symlink config.toml and bin/ only (sessions/ is runtime state, don't symlink the whole dir)
  xdg.configFile."herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/herdr/config.toml";
  xdg.configFile."herdr/bin".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/herdr/bin";

  # yazi ships in home.packages on every host and marimo is used on every host,
  # but both configs were reachable only through the ~/.config symlink, so hosts
  # without it silently ran on default settings.
  xdg.configFile."yazi".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/yazi";
  xdg.configFile."marimo".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/marimo";

  # unfreeパッケージを許可
  nixpkgs.config.allowUnfree = true;
}
