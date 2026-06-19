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
    # AI コーディング CLI（claude.nix が CLAUDE_CODE_EFFORT_LEVEL も設定）
    ../modules/claude.nix
    ../modules/codex.nix
  ];

  home.username = username;
  home.homeDirectory = lib.mkDefault "${homeRoot}/${username}";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    marp-cli
    terraform
    heroku

    # lightgbm dependencies
    llvmPackages.openmp
    zlib
  ];
}
