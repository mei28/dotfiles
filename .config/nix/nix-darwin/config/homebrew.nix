{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };
    casks = [
      "hammerspoon"
      "aerospace"
      "ngrok"
      "wezterm"
      "font-hack-nerd-font"
      "font-symbols-only-nerd-font"
    ];
    taps = [
      "nikitabobko/tap"
    ];
  };
}
