{
  description = "Midas' declarative NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-primary.url = "github:NixOS/nixpkgs/nixos-25.11";
    apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-primary = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-primary";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-primary,
      home-manager,
      home-manager-primary,
      apple-silicon,
      sops-nix,
      ...
    }:
    {
      templates = {
        zig = {
          path = ./templates/zig;
          description = "Zig development shell";
        };
        rust = {
          path = ./templates/rust;
          description = "Rust development shell";
        };
      };

      nixosConfigurations.m22 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./hosts/m22.nix
          apple-silicon.nixosModules.apple-silicon-support
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
        ];
      };

      nixosConfigurations.primary = nixpkgs-primary.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/primary.nix
          home-manager-primary.nixosModules.home-manager
        ];
      };

      nixosConfigurations.test = nixpkgs-primary.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./hosts/test.nix
          home-manager-primary.nixosModules.home-manager
        ];
      };
    };
}
