{
  inputs,
  lib,
  pkgs,
  system,
  ...
}: let
  inherit (import ./options.nix) username;
in {
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    git
    curl
    alejandra
    gitui
    arxiv-latex-cleaner
    bash-completion
    bat
    coreutils
    csvlens
    deno
    efm-langserver
    fastfetch
    fd
    ffmpeg
    ffmpegthumbnailer
    fzf
    gh
    ghostscript
    gitui
    heroku
    imagemagick
    jujutsu
    jq
    sqlite
    libevent
    libgit2
    libheif
    libssh2
    llvm
    luajit
    luarocks
    neovim
    nodejs_20
    openssl
    ripgrep
    rust-analyzer
    serie
    unzip
    tig
    tldr
    tmux
    tmux-mem-cpu-load
    tokei
    trash-cli
    tree
    tree-sitter
    unbound
    wget
    yazi
    zoxide
    nerdfonts
    cargo-generate
  ];

  # 環境変数を sessionVariables に設定
  home.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };

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

