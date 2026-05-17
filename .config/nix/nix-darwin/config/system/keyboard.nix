{
  # Key repeat: fastest possible, beyond macOS GUI limits
  # InitialKeyRepeat: delay before repeat starts (unit: 15ms)
  # KeyRepeat:        interval between repeats (unit: 15ms)
  system.defaults.NSGlobalDomain = {
    InitialKeyRepeat = 10;
    KeyRepeat = 1;
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
