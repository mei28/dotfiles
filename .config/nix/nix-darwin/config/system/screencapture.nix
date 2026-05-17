{
  system.defaults.screencapture = {
    type = "png";
    disable-shadow = true;
    # location omitted: keep macOS default (~/Desktop).
    # NOTE: defaults plist does not expand "~", so absolute path required if overriding.
    # show-thumbnail omitted: keep macOS default (true).
  };
}
