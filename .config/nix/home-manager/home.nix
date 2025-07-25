{
  inputs,
  lib,
  pkgs,
  pkgsUnstable,
  system,
  ...
}:
let
  inherit (import ./options.nix) username;
  # OS ごとにルートを切替え
  homeRoot = if pkgs.stdenv.isDarwin then "/Users" else "/home"; # :contentReference[oaicite:0]{index=0}
in
{
  home.username = username;
  home.homeDirectory = lib.mkDefault "${homeRoot}/${username}";
  # unfreeパッケージを許可
  nixpkgs.config.allowUnfree = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";

  home.packages =
    with pkgs;
    [
      # Development Tools
      gh
      sqlite
      # nodejs_20
      nodejs_24
      rust-analyzer
      cargo-generate
      llvm
      neovim
      efm-langserver
      bat
      just

      # Language Runtimes and Build Tools
      deno
      luajit
      luarocks
      uv
      cargo
      rustc
      go
      google-cloud-sdk
      pnpm
      claude-code
      terraform
      postgresql

      # lightgbm
      llvmPackages.openmp # libomp.dylib
      zlib # libz.1.dylib llvmPackages.libcxx # libc++.1.dylib

      # lsp
      pyright
      gopls

      # formatter linter
      nixfmt-rfc-style

      # System Utilities and CLI Enhancements
      git-lfs
      fd
      tmux-mem-cpu-load
      trash-cli
      tree
      tree-sitter
      wget
      curl
      zip
      unzip
      ripgrep
      # nerd-fonts

      # File Management
      coreutils
      ffmpeg
      ffmpegthumbnailer
      imagemagick
      openssl
      yazi

      # Others (LaTeX, etc.)
      arxiv-latex-cleaner
      ghostscript
      csvlens
      heroku
      tldr

      # mei
      inputs.cliperge.defaultPackage.${system}
      inputs.sgh.defaultPackage.${system}
      inputs.portsage.defaultPackage.${system}
      inputs.git-gardener.defaultPackage.${system}
    ]
    ++ [ pkgsUnstable.fzf-make ];
  # 環境変数を sessionVariables に設定
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

  imports = [

    ./modules/bash.nix
    # cli
    ./modules/git.nix
    ./modules/gitui.nix
    ./modules/fzf.nix
    ./modules/tmux.nix
    ./modules/fastfetch.nix
    ./modules/zoxide.nix
    ./modules/jujutsu.nix

    # formatter linter
    ./modules/ruff.nix
    ./modules/zellij.nix

    # emacs
    # ./modules/emacs.nix

    # ssh
    ./modules/ssh.nix

  ];

  # Home Manager programs configuration
  programs.home-manager.enable = true;

  # neovim
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.sqlite-lua;
      config = "vim.g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.dylib'";
    }
  ];

}
