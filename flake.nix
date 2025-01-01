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
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      flake-utils,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # username = "mei";
        inherit (import ./.config/nix/home-manager/options.nix) username;
        pkgs = import nixpkgs { inherit system; };
      in
      {
        formatter = pkgs.nixfmt-rfc-style;

        # Home Manager + nix-darwin 設定
        legacyPackages = {
          inherit (pkgs) home-manager;

          # Home Manager configuration
          homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgs;
            extraSpecialArgs = { inherit inputs system; };
            modules = [ ./.config/nix/home-manager/home.nix ];
          };

          # macOS (nix-darwin) の設定
          darwinConfigurations.mei-darwin = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
              ./.config/nix/nix-darwin/default.nix
            ];
          };
        };
      }
    );
}
