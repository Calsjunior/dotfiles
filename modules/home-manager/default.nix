{ lib, ... }:
let
  allFiles = lib.filesystem.listFilesRecursive ./.;
  modules = lib.filter (
    file: lib.hasSuffix ".nix" (toString file) && baseNameOf file != "default.nix"
  ) allFiles;
in
{
  imports = modules;
}
