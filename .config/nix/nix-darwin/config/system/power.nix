{
  # Minutes. 0 = never.
  # displaysleep <= sleep must hold, otherwise display-only sleep is unreachable.
  power.sleep = {
    computer = 15;
    display = 5;
    # allowSleepByLidClose: leave at OS default
  };

  # disksleep intentionally unset (modern SSDs don't benefit much; macOS default OK)
}
