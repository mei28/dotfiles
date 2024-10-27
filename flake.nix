{
  description = "Multi-platform configuration for Mac and Linux";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    ...
  }: let
    # Define the system variable based on the current platform
    system =
      if self ? darwinConfigurations
      then "aarch64-darwin"
      else "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    packages.${system}.my-packages = pkgs.buildEnv {
      name = "my-packages-list";
      paths = with pkgs; [];
    };

    # nix run .#update
    apps.${system}.update = {
      type = "app";
      program = toString (pkgs.writeShellScript "update-script" ''
        set -e
        echo "Updating flake..."
        nix flake update
        echo "Updating profile..."
        if [[ "$(uname)" == "Darwin" ]]; then
          echo "Updating home-manager for macOS..."
          nix run nixpkgs#home-manager -- switch --flake .#mySharedConfig
          echo "Updating nix-darwin..."
          nix run nix-darwin -- switch --flake .#mei-darwin
        else
          echo "Updating home-manager for Linux..."
          nix run nixpkgs#home-manager -- switch --flake .#myLinuxHome
        fi
        echo "Update Complete!"
      '');
    };

    # Home Manager configuration for Linux
    homeConfigurations.myLinuxHome = home-manager.lib.homeManagerConfiguration {
      pkgs = pkgs;
      extraSpecialArgs = {inherit (self) inputs;};
      modules = [
        ./.config/nix/home-manager/home-linux.nix
      ];
    };

    # Shared Home Manager configuration for both platforms
    homeConfigurations.mySharedConfig = home-manager.lib.homeManagerConfiguration {
      pkgs = pkgs;
      extraSpecialArgs = {inherit (self) inputs;};
      modules = [
        ./.config/nix/home-manager/home-shared.nix
      ];
    };

    # nix-darwin configuration for macOS with Homebrew module integration
    darwinConfigurations.mei-darwin = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin"; # Specify the macOS system directly here
      modules = [
        ./.config/nix/nix-darwin/default.nix
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true; # For Apple Silicon compatibility with Intel apps
            user = "mei"; # Replace "mei" with your actual username
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };
            mutableTaps = false;
          };
        }
      ];
    };
  };
}
