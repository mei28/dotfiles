{
  description = "Multi-platform configuration for Mac and Linux";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/master";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/master";
    nixpkgs-24.url = "github:nixos/nixpkgs/nixos-24.11";
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
    cliperge = {
      url = "github:mei28/cliperge";
    };
    sgh = {
      url = "github:mei28/sgh";
    };
    portsage = {
      url = "github:mei28/PortSage";
    };
    git-gardener = {
      url = "github:mei28/git-gardener";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-24,
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
        pkgsUnstable = import inputs.nixpkgs-unstable { inherit system; };
        pkgs24 = import inputs.nixpkgs-24 { inherit system; };
      in
      {
        formatter = pkgs.nixfmt-rfc-style;

        # Home Manager + nix-darwin
        legacyPackages = {
          inherit (pkgs) home-manager;

          # Home Manager configuration (macOS)
          homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgs;
            extraSpecialArgs = {
              inherit
                inputs
                system
                pkgsUnstable
                pkgs24
                ;
            };
            modules = [ ./.config/nix/home-manager/profiles/macos.nix ];
          };

          # Home Manager configuration (Remote/EC2)
          homeConfigurations."${username}-remote" = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgs;
            extraSpecialArgs = {
              inherit
                inputs
                system
                pkgsUnstable
                pkgs24
                ;
            };
            modules = [ ./.config/nix/home-manager/profiles/remote.nix ];
          };

          # macOS (nix-darwin)
          darwinConfigurations.mei-darwin = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
              ./.config/nix/nix-darwin/default.nix
              { _module.args = { inherit username; }; }
            ];
          };
        };
      }
    );
}
