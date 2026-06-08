{
  config,
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
    ../profiles/macos.nix
  ];

  home.username = username;
  home.homeDirectory = lib.mkDefault "${homeRoot}/${username}";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    claude-code
    marp-cli
    google-cloud-sdk
    terraform
    heroku

    # lightgbm dependencies
    llvmPackages.openmp
    zlib
  ];

  home.sessionVariables = {
    CLAUDE_CODE_EFFORT_LEVEL = "max";
  };
}
