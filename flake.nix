{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    # Freshness pin for individual packages (e.g. ollama-cuda on oryp11)
    # that need a newer revision than the stable channel ships.
    nixpkgs-latest.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # AeroThemePlasma (Windows 7 look for KDE Plasma 6). Its flake requires
    # nixos-unstable, so follow the unstable pin rather than stable nixpkgs.
    aerothemeplasma-nix = {
      url = "github:nyakase/aerothemeplasma-nix";
      inputs.nixpkgs.follows = "nixpkgs-latest";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-latest, nixos-wsl, nixvim
    , home-manager, agenix, darwin, utils, aerothemeplasma-nix, ... }@inputs:
    let
      # Systems the dev container image can be built for. Note that building an
      # aarch64-linux image from aarch64-darwin needs a Linux builder
      # (nix.linux-builder.enable) or a remote builder.
      containerSystems = [ "x86_64-linux" "aarch64-linux" ];
      forEachContainerSystem = f: nixpkgs.lib.genAttrs containerSystems f;

      containerPkgs = system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      containerHome = system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = containerPkgs system;
          modules = [ ./hosts/container/home.nix ];
          extraSpecialArgs = {
            inherit inputs;
            headless = true;
          };
        };
    in {
      nixosModules = import ./modules { lib = nixpkgs.lib; };
      nixosConfigurations = {
        oryp11 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/oryp11/configuration.nix
            utils.nixosModules.autoGenFromInputs
            home-manager.nixosModules.home-manager
            agenix.nixosModules.age
            nixvim.nixosModules.nixvim
          ];
          specialArgs = { inherit inputs; };
        };
        proxmox-media = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/proxmox/media/configuration.nix
            utils.nixosModules.autoGenFromInputs
            home-manager.nixosModules.home-manager
            agenix.nixosModules.age
            nixvim.nixosModules.nixvim
          ];
          specialArgs = { inherit inputs; };
        };
        media-serving = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/media_serving/configuration.nix
            utils.nixosModules.autoGenFromInputs
            home-manager.nixosModules.home-manager
            agenix.nixosModules.age
            nixvim.nixosModules.nixvim
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
            nixvim.nixosModules.nixvim
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
            nixvim.nixDarwinModules.nixvim
          ];
          specialArgs = { inherit inputs; };
        };
      };

      # Standalone Home Manager generation used by the dev container image.
      # Also usable directly:
      #   home-manager switch --flake .#container-x86_64-linux
      homeConfigurations = nixpkgs.lib.mapAttrs' (system: cfg:
        nixpkgs.lib.nameValuePair "container-${system}" cfg)
        (forEachContainerSystem containerHome);

      packages = forEachContainerSystem (system:
        let
          mkImage = args:
            import ./hosts/container/image.nix ({
              pkgs = containerPkgs system;
              homeConfiguration = containerHome system;
            } // args);
        in rec {
          # Image tarball: nix build .#devcontainer && docker load < result
          devcontainer = mkImage { };
          # Streams the tarball instead of writing it to the store:
          #   nix run .#devcontainer-stream | docker load
          devcontainer-stream = mkImage { stream = true; };
          default = devcontainer;
        });
    };
}
