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
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        # username = "mei";
        inherit (import ./.config/nix/home-manager/options.nix) username;
        pkgs = import nixpkgs {inherit system;};
      in {
        formatter = pkgs.nixfmt-rfc-style;

        # Application update script as an app
        apps = {
          update = {
            type = "app";
            program = "${pkgs.writeShellScriptBin "update" ''
              set -e
              echo "Updating flake..."
              nix flake update
              echo "Updating home-manager..."
              nix run nixpkgs#home-manager -- switch --flake .#${username}
              echo "Update complete!"
              nix run nix-darwin -- switch --flake .#mei-darwin
            ''}/bin/update";
          };
        };

        # Legacy Packages and Home Manager + nix-darwin configurations
        legacyPackages = {
          inherit (pkgs) home-manager;

          # Home Manager configuration
          homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgs;
            extraSpecialArgs = {inherit inputs system;};
            modules = [./.config/nix/home-manager/home.nix];
          };

          # nix-darwin configuration for macOS with Homebrew integration
          darwinConfigurations.mei-darwin = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin"; # Specify the macOS system
            modules = [
              ./.config/nix/nix-darwin/default.nix
            ];
          };
        };
      }
    );
}
