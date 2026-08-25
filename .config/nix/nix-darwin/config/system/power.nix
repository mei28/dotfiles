{
  # Minutes. 0 = never.
  # displaysleep <= sleep must hold, otherwise display-only sleep is unreachable.
  power.sleep = {
    computer = 15;
    display = 5;
    # allowSleepByLidClose: leave at OS default
  };

  # disksleep intentionally unset (modern SSDs don't benefit much; macOS default OK)

  # nix-darwin applies power.sleep through `systemsetup -setComputerSleep`, which
  # only writes the AC profile. Battery kept its own value (1 minute here), so
  # unplugging turned a locked screen into a suspended machine within a minute.
  # pmset -b is the only way to reach that profile; postActivation runs after the
  # systemsetup calls above.
  #
  # This is the backstop, not the mechanism: holding work across a lock is the
  # job of .hammerspoon/caffeine.lua (automatic) and `cafwake` (manual), both of
  # which assert PreventUserIdleSystemSleep and override these timers entirely.
  system.activationScripts.postActivation.text = ''
    echo "configuring battery power..." >&2
    pmset -b sleep 30
    pmset -b displaysleep 5
  '';
}
