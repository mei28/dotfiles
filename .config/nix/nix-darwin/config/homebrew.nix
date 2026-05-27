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
      "azookey"
      "marta"
      "raycast"
      "thaw"
    ];
    brews = [
      "lusingander/tap/serie"
    ];
  };
}
