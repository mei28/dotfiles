{
  pkgs,
  ...
}:
let
  # 環境変数からユーザー名を取得 (impure 必須)
  # sudo 経由実行で USER=root になるため SUDO_USER を優先
  sudoUser = builtins.getEnv "SUDO_USER";
  envUser = builtins.getEnv "USER";
  username =
    if sudoUser != "" then
      sudoUser
    else if envUser != "" && envUser != "root" then
      envUser
    else
      "user";

  nix = import ./config/nix.nix;
  fonts = import ./config/fonts.nix { inherit pkgs; };
  services = import ./config/services.nix;
  kanata = import ./config/kanata.nix { inherit username; };

  # macOS system.* settings (split per concern under config/system/)
  system = import ./config/system { inherit pkgs; };
  systemKeyboard = import ./config/system/keyboard.nix;
  systemDock = import ./config/system/dock.nix;
  systemFinder = import ./config/system/finder.nix;
  systemScreencapture = import ./config/system/screencapture.nix;
  systemTrackpad = import ./config/system/trackpad.nix;
  systemMenubar = import ./config/system/menubar.nix;
  systemPower = import ./config/system/power.nix;
in
{
  imports = [
    nix
    services
    fonts
    kanata

    system
    systemKeyboard
    systemDock
    systemFinder
    systemScreencapture
    systemTrackpad
    systemMenubar
    systemPower
  ];

  system.primaryUser = username;

  # /etc/shells に nix bash を登録 (chsh で login shell に指定可能にする)
  environment.shells = [ pkgs.bash ];
}
