{
  pkgs,
  ...
}: let
  # 環境変数からユーザー名を取得 (impure 必須)
  # sudo 経由実行で USER=root になるため SUDO_USER を優先
  sudoUser = builtins.getEnv "SUDO_USER";
  envUser = builtins.getEnv "USER";
  username =
    if sudoUser != "" then sudoUser
    else if envUser != "" && envUser != "root" then envUser
    else "user";

  nix = import ./config/nix.nix;
  fonts = import ./config/fonts.nix {inherit pkgs;};
  services = import ./config/services.nix;
  system = import ./config/system.nix {inherit pkgs;};
  homebrew = import ./config/homebrew.nix;
  kanata = import ./config/kanata.nix { inherit username; };
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
