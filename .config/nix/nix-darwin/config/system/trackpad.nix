{
  system.defaults.trackpad = {
    Clicking = true;             # tap to click
    TrackpadRightClick = true;   # two-finger right click
    TrackpadThreeFingerDrag = true;
  };

  # Disable natural scrolling (mouse-style: swipe down = content down)
  # Lives in NSGlobalDomain but conceptually a trackpad/mouse setting.
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;
}
