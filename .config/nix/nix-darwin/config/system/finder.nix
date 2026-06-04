{
  system.defaults.finder = {
    AppleShowAllFiles = true;
    AppleShowAllExtensions = true;
    _FXShowPosixPathInTitle = true;
    ShowPathbar = true;
    ShowStatusBar = true;
    FXPreferredViewStyle = "clmv"; # カラム表示
  };

  # Show file extensions globally (mirrors Finder setting)
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
}
