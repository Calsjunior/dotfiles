{
  description = "Based NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia.url = "github:noctalia-dev/noctalia-shell/v5";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
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
                  sharedModules = [ ./modules/home-manager ];
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

      templates = {
        web = {
          path = ./templates/web;
        };
      };
    };
}
