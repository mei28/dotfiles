{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # cleanup = "uninstall";
    };
    casks = [
      "hammerspoon"
      "nikitabobko/tap/aerospace"
      # "ngrok"
      "wezterm@nightly"
      "ghostty"
      "cmux"
      "azookey"
      "marta"
      "raycast"
      "thaw"
    ];
    brews = [
      # serie は base.nix の nix パッケージ側に一本化（Linux ホストでも効くため）
      "displayplacer"
    ];
  };
}
