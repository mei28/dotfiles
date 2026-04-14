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
      "ngrok"
      "wezterm"
      "wezterm@nightly"
      "font-hack-nerd-font"
      "font-symbols-only-nerd-font"
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
