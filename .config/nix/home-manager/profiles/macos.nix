{
  inputs,
  lib,
  pkgs,
  system,
  ...
}:
let
  inherit (import ../options.nix) username;
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
