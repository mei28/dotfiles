{
  pkgs,
  ...
}:
{
  imports = [
    ../default.nix
    ../config/homebrew.nix
  ];
}
