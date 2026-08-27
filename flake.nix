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
      mkHost =
        hostname: username: extraModules:
        let
          dotfilesPath = "/home/${username}/dotfiles";
          globalArgs = {
            inherit
              inputs
              hostname
              dotfilesPath
              ;
            user = username;
          };
        in
        nixpkgs.lib.nixosSystem {
          specialArgs = globalArgs;
          modules = [
            ./hosts/${hostname}/configuration.nix
            ./modules/nixos
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = import ./hosts/${hostname}/home.nix;
                extraSpecialArgs = globalArgs;
                backupFileExtension = "backup";
                sharedModules = [
                  ./modules/home-manager
                ];
              };
            }
          ]
          ++ extraModules;
        };
    in
    {
      nixosConfigurations =
        let
          hosts = {
            ares = {
              user = "cal";
              extraModules = [ ];
            };
            athena = {
              user = "cal";
              extraModules = [ ];
            };
          };
        in
        nixpkgs.lib.mapAttrs (
          hostname: settings: mkHost hostname settings.user settings.extraModules
        ) hosts;

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
          typst = mkTemplate "typst";
        };
    };
}
