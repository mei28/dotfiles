{
  system.defaults.trackpad = {
    Clicking = true; # tap to click
    TrackpadRightClick = true; # two-finger right click
    TrackpadThreeFingerDrag = true;
  };

  # Disable natural scrolling (mouse-style: swipe down = content down)
  # Lives in NSGlobalDomain but conceptually a trackpad/mouse setting.
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;

  # Tracking speed: 0.0 (slowest) – 3.0 (fastest)
  system.defaults.NSGlobalDomain."com.apple.trackpad.scaling" = 3.0;

  # Click threshold: 0 = light, 1 = medium, 2 = firm
  system.defaults.CustomUserPreferences = {
    "com.apple.AppleMultitouchTrackpad" = {
      FirstClickThreshold = 0;
      SecondClickThreshold = 0;
    };
    "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
      FirstClickThreshold = 0;
      SecondClickThreshold = 0;
    };
  };
}
