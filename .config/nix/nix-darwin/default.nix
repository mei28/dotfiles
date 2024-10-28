{
  pkgs,
  username,
  ...
}: let
  nix = import ./config/nix.nix;
  fonts = import ./config/fonts.nix {inherit pkgs;};
  services = import ./config/services.nix;
  system = import ./config/system.nix {inherit pkgs;};
  homebrew = import ./config/homebrew.nix;
in {
  imports = [
    nix
    services
    fonts 
    system 
    homebrew
  ];
}
