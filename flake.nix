{
  description = "Based NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
        "ares" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              inputs
              user
              ;
          };
          modules = [
            ./hosts/ares/configuration.nix
            ./modules/nixos

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user} = import ./hosts/ares/home.nix;
                sharedModules = [ ./modules/home-manager ];
                extraSpecialArgs = { inherit inputs user; };
                backupFileExtension = "backup";
              };
            }
          ];
        };
      };
    };
}
