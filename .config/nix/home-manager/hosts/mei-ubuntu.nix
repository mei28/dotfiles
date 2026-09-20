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
  # 私物 Ubuntu デスクトップ。babalab-mac の Linux 版。
  # 外したもの:
  # - profiles/macos.nix: hammerspoon / aerospace / karabiner / raycast / cmux は
  #   mac 専用。wezterm と ghostty の設定は ~/.config -> dotfiles/.config の
  #   symlink (setup.sh) で届くので、ここで宣言しない。
  # - lightgbm 用の llvmPackages.openmp / zlib: development.nix の
  #   DYLD_FALLBACK_LIBRARY_PATH に載せるための mac 回避策。Linux の lightgbm は
  #   system の libgomp を見るため、nix 側に置いても効かない。
  imports = [
    ../profiles/base.nix
    ../profiles/development.nix
    # AI コーディング CLI
    ../modules/claude.nix
    ../modules/codex.nix
    ../modules/opencode.nix
    # SSH 中は GNOME の自動サスペンドを止める (systemd user service)
    ../modules/inhibit-suspend-on-ssh.nix
  ];

  home.username = username;
  home.homeDirectory = lib.mkDefault "${homeRoot}/${username}";
  home.stateVersion = "25.05";

  # wezterm は nix ではなく APT repo (apt.fury.io/wez) から入れる。GUI アプリは
  # apt 側に寄せて .desktop 登録と apt upgrade での追従を任せる。手順は README。
  home.packages = with pkgs; [
    marp-cli
    terraform
    heroku
    kaggle

    # nvim-treesitter (main branch) fetches and builds parsers through the
    # tree-sitter CLI (>= 0.25). The C compiler comes from apt's build-essential.
    # Only this host for now; the mac side gets the CLI elsewhere (unverified).
    tree-sitter

    inputs.herdr.packages.${system}.default
  ];
}
