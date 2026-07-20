{
  description = "Based NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-index-database,
      sops-nix,
      ...
    }@inputs:
    let
      user = "cal";
      mkHost =
        hostname: extraModules:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs user hostname; };
          modules = [
            ./hosts/${hostname}/configuration.nix
            ./modules/nixos
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user} = import ./hosts/${hostname}/home.nix;
                extraSpecialArgs = { inherit inputs user hostname; };
                backupFileExtension = "backup";
                sharedModules = [
                  ./modules/home-manager
                  nix-index-database.homeModules.nix-index
                ];
              };
            }
          ]
          ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        "ares" = mkHost "ares" [ ];
        "athena" = mkHost "athena" [ ];
      };

      templates =
        let
          mkTemplate = name: {
            path = ./templates/${name};
            description = "${name} development environment";
          };
        in
        {
          web = mkTemplate "web";
          c-cpp = mkTemplate "c-cpp";
        };
    };
}
