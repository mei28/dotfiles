{
  config,
  inputs,
  lib,
  pkgs,
  system,
  ...
}:
let
  # 環境変数からユーザー名を取得 (impure 必須)
  runtimeUser = builtins.getEnv "USER";
  username = if runtimeUser != "" then runtimeUser else "user";
  homeRoot = if pkgs.stdenv.isDarwin then "/Users" else "/home";
in
{
  # base と development をインポート
  imports = [
    ./base.nix
    ./development.nix
    # ../modules/sketcher.nix
  ];

  # ユーザー設定
  home.username = username;
  home.homeDirectory = lib.mkDefault "${homeRoot}/${username}";

  # stateVersion
  home.stateVersion = "25.05";

  # macOS専用パッケージ
  home.packages = with pkgs; [
    # macOS特有のツール（必要に応じて追加）
    # 既存のhome.nixから移行したい追加パッケージがあればここに

    # その他
    git-lfs
    ffmpeg
    ffmpegthumbnailer
    imagemagick
    openssl
    arxiv-latex-cleaner
    ghostscript
    heroku
    google-cloud-sdk
    terraform
    claude-code
    tree-sitter
    marp-cli

    # lightgbm dependencies
    llvmPackages.openmp
    zlib
  ];

  # dotfiles へ生 symlink を貼る (mkOutOfStoreSymlink: store コピーせず編集即反映)
  # ホーム直下
  home.file.".hammerspoon".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.hammerspoon";
  home.file.".skhdrc".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.skhdrc";
  home.file.".yabairc".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.yabairc";
  home.file.".rye".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.rye";
  home.file.".wezterm.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/wezterm/wezterm.lua";

  # ~/.config 配下 (home-manager 未管理のアプリ)
  xdg.configFile."aerospace".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/aerospace";
  xdg.configFile."wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/wezterm";
  xdg.configFile."karabiner".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/karabiner";
  xdg.configFile."ghostty".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/ghostty";
  xdg.configFile."raycast".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/raycast";

  # 環境変数を sessionVariables に設定（既存の設定を維持）
  home.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.curl.dev}/lib/pkgconfig";
    LDFLAGS = "-L${pkgs.curl.dev}/lib";
    CPPFLAGS = "-I${pkgs.curl.dev}/include";
    DYLD_FALLBACK_LIBRARY_PATH =
      "${pkgs.llvmPackages.openmp}/lib:"
      + "${pkgs.zlib}/lib:"
      + "${pkgs.llvmPackages.libcxx}/lib:"
      + "/usr/lib";
  };
}
