{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs2305.url = "github:nixos/nixpkgs/nixos-23.05";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wsl.inputs.flake-utils.follows = "utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utils = { url = "github:gytis-ivaskevicius/flake-utils-plus"; };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs2305, nixos-hardware, nixos-wsl
    , home-manager, agenix, darwin, utils, ... }@inputs: {
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
        wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/wsl/configuration.nix
            utils.nixosModules.autoGenFromInputs
            home-manager.nixosModules.home-manager
            agenix.nixosModules.age
            # <nixos-wsl/modules>
            # nixos-hardware.nixosModules.common-gpu-nvidia
          ];
          specialArgs = { inherit inputs; };
        };
      };
      darwinConfigurations = {
        "jlittle-mbp" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/darwin/configuration.nix
            home-manager.darwinModules.home-manager
            # other modules specific to macOS
          ];
          specialArgs = { inherit inputs; };
        };
      };
    };
}
