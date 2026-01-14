{
  inputs,
  pkgs,
  pkgsUnstable,
  system,
  ...
}:
{
  # 開発環境用のパッケージ
  home.packages =
    with pkgs;
    [
      # LSP
      pyright
      gopls
      rust-analyzer
      efm-langserver

      # 言語ランタイム
      uv
      nodejs_24
      cargo
      rustc
      go
      deno
      luajit
      luarocks
      bun
      pnpm
      ni

      # ビルドツール
      cargo-generate
      llvm
      sqlite
      postgresql

      # formatter/linter
      nixfmt-rfc-style

      # ruff設定
      # mei's自作ツール
      inputs.cliperge.defaultPackage.${system}
      inputs.sgh.defaultPackage.${system}
      inputs.portsage.defaultPackage.${system}
      inputs.git-gardener.defaultPackage.${system}
    ]
    ++ [ pkgsUnstable.fzf-make ];

  # ruff設定
  imports = [ ../modules/ruff.nix ];

  # 環境変数（開発用）
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
