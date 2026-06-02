{ lib, ... }:
let
  allFiles = lib.filesystem.listFilesRecursive ./.;
  modules = lib.filter (
    file: lib.hasSuffix ".nix" (builtins.toString file) && builtins.baseNameOf file != "default.nix"
  ) allFiles;
in
{
  imports = modules;
}
