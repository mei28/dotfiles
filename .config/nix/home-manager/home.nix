{
  inputs,
  lib,
  pkgs,
  system,
  ...
}:
let
  inherit (import ./options.nix) username;
in
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    # Development Tools
    gh
    sqlite
    nodejs_20
    rust-analyzer
    cargo-generate
    llvm
    neovim
    efm-langserver
    jujutsu

    # Language Runtimes and Build Tools
    deno
    luajit
    luarocks
    uv
    cargo

    # lsp
    pyright

    # formatter linter
    nixfmt-rfc-style

    # System Utilities and CLI Enhancements
    git-lfs
    fd
    bat
    tmux-mem-cpu-load
    trash-cli
    tree
    tree-sitter
    wget
    unzip
    ripgrep
    zoxide
    nerdfonts

    # File Management
    coreutils
    ffmpeg
    ffmpegthumbnailer
    imagemagick
    openssl yazi tokei

    # Others (LaTeX, etc.)
    arxiv-latex-cleaner
    ghostscript
    csvlens
    heroku
    tig
    tldr
    alejandra
  ];
  # 環境変数を sessionVariables に設定
  home.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };

  imports = [
    # cli 
    ./modules/git.nix
    ./modules/gitui.nix
    ./modules/fzf.nix
    ./modules/tmux.nix
    ./modules/fastfetch.nix

    # formater linter
    ./modules/ruff.nix
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
