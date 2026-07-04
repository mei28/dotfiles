{
  inputs,
  lib,
  pkgs,
  system,
  ...
}:
let
  runtimeUser = builtins.getEnv "USER";
  username = if runtimeUser != "" then runtimeUser else "user";
  homeRoot = if pkgs.stdenv.isDarwin then "/Users" else "/home";
in
{
  imports = [
    ../profiles/base.nix
    ../profiles/development.nix
  ];

  home.username = username;
  home.homeDirectory = lib.mkDefault "${homeRoot}/${username}";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    inputs.herdr.packages.${system}.default
  ];
}
