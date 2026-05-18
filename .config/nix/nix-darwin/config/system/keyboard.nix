{
  # Key repeat: macOS defaults.
  # Faster values (10/1, 15/3) caused chattering-like repeats.
  # InitialKeyRepeat: delay before repeat starts (unit: 15ms) — 68 ≈ 1s
  # KeyRepeat:        interval between repeats (unit: 15ms)   — 6  = 90ms
  system.defaults.NSGlobalDomain = {
    InitialKeyRepeat = 68;
    KeyRepeat = 6;
  };

  # Authenticate sudo with Touch ID.
  # reattach = true wires up pam_reattach so it also works inside
  # tmux / screen / zellij (which otherwise can't reach the GUI).
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # system.keyboard left unset to avoid conflict with kanata
  # Auto-correct / smart quotes also left at macOS defaults
}
