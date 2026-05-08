{
  pkgs,
  ...
}: let
  # 環境変数からユーザー名を取得 (impure 必須)
  runtimeUser = builtins.getEnv "USER";
  username = if runtimeUser != "" then runtimeUser else "user";

  nix = import ./config/nix.nix;
  fonts = import ./config/fonts.nix {inherit pkgs;};
  services = import ./config/services.nix;
  system = import ./config/system.nix {inherit pkgs;};
  homebrew = import ./config/homebrew.nix;
  kanata = import ./config/kanata.nix;
in {
  imports = [
    nix
    services
    fonts
    system
    homebrew
    kanata
  ];

  system.primaryUser = username;
}
