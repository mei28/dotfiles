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
    # AI コーディング CLI
    ../modules/claude.nix
    ../modules/codex.nix
    ../modules/opencode.nix
  ];

  home.username = username;
  home.homeDirectory = lib.mkDefault "${homeRoot}/${username}";
  home.stateVersion = "25.05";

  # sbi-mac 専用の opencode オーバーレイを読ませる。
  # 共有 opencode.json とマージされ、kadode provider と brave-search MCP が載る。
  # babalab-mac は自前サーバが無いため env 未設定のまま（provider/mcp ともロードなし）。
  # ファイル実体は dotfiles/.config/opencode/opencode.sbi-mac.json。
  home.sessionVariables = {
    OPENCODE_CONFIG =
      "${config.home.homeDirectory}/dotfiles/.config/opencode/opencode.sbi-mac.json";
    # kadode の API キー。VPN 経由は dummy で通る。Cloudflare Access 経由に切替える時は
    # ここを実トークンに置き換える。config JSON には書かない（{env:KADODE_TOKEN} 参照）。
    KADODE_TOKEN = "no-key-required";
  };

  home.packages = with pkgs; [
    inputs.herdr.packages.${system}.default
  ];
}
