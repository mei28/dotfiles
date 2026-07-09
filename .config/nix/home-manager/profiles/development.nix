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

      # Custom tools
      inputs.cliperge.defaultPackage.${system}
      inputs.sgh.defaultPackage.${system}
      inputs.portsage.defaultPackage.${system}
      inputs.bonsai.packages.${system}.default
    ]
    # Cloud: nixpkgs の google-cloud-sdk は Linux ビルドが不安定なため macOS のみ
    ++ lib.optionals stdenv.isDarwin [ google-cloud-sdk ]
    ++ lib.optionals stdenv.isDarwin [ inputs.wabi.packages.${system}.default ]
    ++ [ fzf-make ];

  # ruff + mutagen
  imports = [
    ../modules/ruff.nix
    ../modules/mutagen.nix
  ];

  # Environment variables
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
