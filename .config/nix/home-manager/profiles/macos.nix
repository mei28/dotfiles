{
  config,
  lib,
  ...
}:
{
  # dotfiles へ生 symlink を貼る (mkOutOfStoreSymlink: store コピーせず編集即反映)
  # ホーム直下
  home.file.".hammerspoon".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.hammerspoon";
  home.file.".rye".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.rye";
  home.file.".wezterm.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/wezterm/wezterm.lua";

  # ~/.config 配下 (home-manager 未管理のアプリ)
  xdg.configFile."aerospace".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/aerospace";
  xdg.configFile."wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/wezterm";
  xdg.configFile."karabiner".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/karabiner";
  xdg.configFile."ghostty".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/ghostty";
  xdg.configFile."cmux".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/cmux";
  xdg.configFile."raycast".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/raycast";

  # 環境変数は development.nix が定義する。mac ホストは両方 import するため、
  # ここに同じ定義を置くと重複になる。
}
