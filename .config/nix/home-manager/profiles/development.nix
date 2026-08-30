{
  inputs,
  pkgs,
  system,
  ...
}:
{
  # Development packages
  home.packages =
    with pkgs;
    [
      # LSP
      pyright
      gopls
      rust-analyzer
      efm-langserver
      harper

      # Language runtimes
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

      # Build tools
      cargo-generate
      llvm
      sqlite
      postgresql

      # formatter/linter
      nixfmt

      # Media: ImageMagick delegates APNG decoding to ffmpeg
      ffmpeg

      # Custom tools
      inputs.cliperge.defaultPackage.${system}
      inputs.sgh.defaultPackage.${system}
      inputs.portsage.defaultPackage.${system}
      inputs.bonsai.packages.${system}.default
    ]
    # Cloud: nixpkgs の google-cloud-sdk は Linux ビルドが不安定なため macOS のみ
    ++ lib.optionals stdenv.isDarwin [ google-cloud-sdk ]
    ++ [ fzf-make ];

  # ruff + mutagen
  imports = [
    ../modules/ruff.nix
    ../modules/mutagen.nix
  ];

  # Environment variables
  home.sessionVariables = {
    # nvim を全ツール共通のエディタにする。未設定だと macOS 既定の nano が残り、
    # $VISUAL / $EDITOR を読むツール（opencode の editor_open など）が nano を開く。
    # git は core.editor で個別に nvim を指しているため、これとは独立。
    EDITOR = "nvim";
    VISUAL = "nvim";

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
