{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  username = "mei";
in {
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];
  };

  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";

    packages = with pkgs; [
      git
      curl
      alejandra
      gitui
      wezterm
      arxiv-latex-cleaner
      bash
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
    ];
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
