{
  description = "Based NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
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
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-index-database,
      ...
    }@inputs:
    let
      user = "cal";
    in
    {
      nixosConfigurations = {
        "ares" =
          let
            hostname = "ares";
          in
          nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit
                inputs
                user
                hostname
                ;
            };
            modules = [
              ./hosts/${hostname}/configuration.nix
              ./modules/nixos

              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.${user} = import ./hosts/${hostname}/home.nix;
                  sharedModules = [
                    ./modules/home-manager
                    nix-index-database.homeModules.nix-index
                  ];
                  extraSpecialArgs = { inherit inputs user hostname; };
                  backupFileExtension = "backup";
                };
              }
            ];
          };

        "athena" =
          let
            hostname = "athena";
          in
          nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit
                inputs
                user
                hostname
                ;
            };
            modules = [
              ./hosts/${hostname}/configuration.nix
              ./modules/nixos

              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.${user} = import ./hosts/${hostname}/home.nix;
                  sharedModules = [ ./modules/home-manager ];
                  extraSpecialArgs = { inherit inputs user hostname; };
                  backupFileExtension = "backup";
                };
              }
            ];
          };
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
