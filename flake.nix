{
  description = "Multi-platform configuration for Mac and Linux";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
    bonsai = {
      url = "github:mei28/bonsai";
    };
    wabi = {
      url = "github:mei28/wabi";
    };
    tmux-mutagen-status = {
      url = "github:mei28/tmux-mutagen-status";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      flake-utils,
      neovim-nightly-overlay,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ neovim-nightly-overlay.overlays.default ];
        };
      in
      {
        formatter = pkgs.nixfmt;

        # Home Manager + nix-darwin
        # 属性名は username 非依存。実 username は各 profile が
        # builtins.getEnv "USER" で動的解決 (--impure 必須)
        legacyPackages = {
          inherit (pkgs) home-manager;

          # Home Manager configurations (per host)
          homeConfigurations.babalab-mac = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgs;
            extraSpecialArgs = {
              inherit inputs system;
            };
            modules = [ ./.config/nix/home-manager/hosts/babalab-mac.nix ];
          };

          homeConfigurations.sbi-mac = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgs;
            extraSpecialArgs = {
              inherit inputs system;
            };
            modules = [ ./.config/nix/home-manager/hosts/sbi-mac.nix ];
          };

          homeConfigurations.qia-aws = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgs;
            extraSpecialArgs = {
              inherit inputs system;
            };
            modules = [ ./.config/nix/home-manager/hosts/qia-aws.nix ];
          };

          homeConfigurations.sbi-superpod = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgs;
            extraSpecialArgs = {
              inherit inputs system;
            };
            modules = [ ./.config/nix/home-manager/hosts/sbi-superpod.nix ];
          };

          # macOS (nix-darwin, per host)
          darwinConfigurations.babalab-mac = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
              ./.config/nix/nix-darwin/hosts/babalab-mac.nix
            ];
          };

          darwinConfigurations.sbi-mac = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
              ./.config/nix/nix-darwin/hosts/sbi-mac.nix
            ];
          };
        };
      }
    );
}
