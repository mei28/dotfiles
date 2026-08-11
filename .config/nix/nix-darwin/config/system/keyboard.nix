{
  # Key repeat (unit: 15ms).
  # InitialKeyRepeat: delay before repeat starts — 20 = 300ms
  # KeyRepeat:        interval between repeats   — 2  = 30ms
  # Note: KeyRepeat=1 (15ms) は過去にチャタリングしたため避ける。
  #
  # 制約: InitialKeyRepeat は kanata の hold-time (250ms) より必ず長くすること。
  # 15 (225ms) だと kanata が tap か hold か判定し終える前に macOS が連射を始め、
  # HRM キー (s d f e j k l i) を叩き直したときに同じ文字が大量に入る。
  # 対になる値は .config/kanata/kanata.kbd の hold-time / tap-repress-time。
  system.defaults.NSGlobalDomain = {
    InitialKeyRepeat = 20;
    KeyRepeat = 2;
  };

  # Authenticate sudo with Touch ID.
  # reattach = true wires up pam_reattach so it also works inside
  # tmux / screen (which otherwise can't reach the GUI).
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # Pin CapsLock → Control at the OS level.
  # kanata does not map caps, so double-mapping is safe: caps passes through
  # kanata and macOS converts it to Ctrl.
  # If kanata ever needs caps (e.g. as a layer key), set remapCapsLockToControl = false.
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
  # Auto-correct / smart quotes: macOS defaults のまま運用中。
  # 無効化したい場合は NSGlobalDomain に以下を追加:
  #   NSAutomaticCapitalizationEnabled = false;
  #   NSAutomaticDashSubstitutionEnabled = false;
  #   NSAutomaticPeriodSubstitutionEnabled = false;
  #   NSAutomaticQuoteSubstitutionEnabled = false;
  #   NSAutomaticSpellingCorrectionEnabled = false;
}
