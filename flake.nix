{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs2305.url = "github:nixos/nixpkgs/nixos-23.05";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utils = { url = "github:gytis-ivaskevicius/flake-utils-plus"; };
  };

  outputs = { self, home-manager, nixpkgs, nixpkgs2305, agenix, nixos-hardware
    , utils, ... }@inputs: {
      nixosModules = import ./modules { lib = nixpkgs.lib; };
      nixosConfigurations = {
        iseries = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/iseries/configuration.nix
            utils.nixosModules.autoGenFromInputs
            home-manager.nixosModules.home-manager
            agenix.nixosModules.age
            # nixos-hardware.nixosModules.common-gpu-nvidia
          ];
          specialArgs = { inherit inputs; };
        };
        oryp11 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/oryp11/configuration.nix
            utils.nixosModules.autoGenFromInputs
            home-manager.nixosModules.home-manager
            agenix.nixosModules.age
            # nixos-hardware.nixosModules.common-gpu-nvidia
          ];
          specialArgs = { inherit inputs; };
        };

      };
    };
}
