{
  description = "A Nix-flake-based C/C++ development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs, system }:
        {
          default = pkgs.mkShell {
            # Use packages or nativeBuildInputs here for tools
            packages =
              with pkgs;
              [
                clang-tools
                gnumake
                valgrind
                self.formatter.${system}
              ]
              ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ gdb ];

            # Use buildInputs for libraries/header files
            # buildInputs = with pkgs; [ <library> ];
          };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt);
    };
}
