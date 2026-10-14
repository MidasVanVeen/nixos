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
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/v0.7.0";
    omnibin = {
      url = "github:MidasVanVeen/omnibin";
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
      comin,
      nix-flatpak,
      omnibin,
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
        specialArgs = { inherit omnibin; };
        modules = [
          ./hosts/m22.nix
          comin.nixosModules.comin
          apple-silicon.nixosModules.apple-silicon-support
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          ({ config, ... }: {
            home-manager.users.${config.my.user.name}.imports = [
              nix-flatpak.homeManagerModules.nix-flatpak
            ];
          })
        ];
      };

      nixosConfigurations.primary = nixpkgs-primary.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/primary.nix
          comin.nixosModules.comin
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
