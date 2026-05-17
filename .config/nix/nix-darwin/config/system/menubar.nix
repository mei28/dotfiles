{
  # Clock: 24h + date + day of week, no seconds
  system.defaults.menuExtraClock = {
    Show24Hour = true;
    ShowDate = 1;        # 0=auto, 1=always show, 2=never
    ShowDayOfWeek = true;
    ShowSeconds = false;
  };

  # controlcenter (Bluetooth / Sound / AirDrop visibility) intentionally
  # left to `thaw` (homebrew cask) + GUI management.
}
