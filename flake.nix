{
  description = "Minimal package definition for aarch64-darwin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    neovim-nightly-overlay,
  }: let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system}.extend (
      neovim-nightly-overlay.overlays.default
    );
  in {
    packages.${system}.my-packages = pkgs.buildEnv {
      name = "my-packages-list";
      paths = with pkgs; [
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
        jj
        jq
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
      ];
    };

    # nix run .#update
    apps.${system}.update = {
      type = "app";
      program = toString (pkgs.writeShellScript "update-script" ''
        set -e
        echo "Updating flake..."
        nix flake update
        echo "Updating profile..."
        nix profile upgrade my-packages
        echo "Update complete!"
      '');
    };
  };
}
