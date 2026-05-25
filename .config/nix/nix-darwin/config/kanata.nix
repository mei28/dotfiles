{ username, ... }: {
  homebrew.brews = [ "kanata" ];

  # Hammerspoon から sudo 無パスワードで kanata daemon を制御するための sudoers
  environment.etc."sudoers.d/kanata" = {
    text = ''
      ${username} ALL=(root) NOPASSWD: /bin/launchctl bootstrap system /Library/LaunchDaemons/dev.mei.kanata-internal.plist, /bin/launchctl bootout system /Library/LaunchDaemons/dev.mei.kanata-internal.plist, /bin/launchctl kickstart -k system/dev.mei.kanata-internal
    '';
  };

  # /Applications/kanata に symlink (TCC で選択しやすく)
  system.activationScripts.postActivation.text = ''
    echo "Linking /Applications/kanata -> /opt/homebrew/bin/kanata"
    /bin/ln -sf /opt/homebrew/bin/kanata /Applications/kanata
  '';

  launchd.daemons.kanata-internal = {
    serviceConfig = {
      Label = "dev.mei.kanata-internal";
      ProgramArguments = [
        "/opt/homebrew/bin/kanata"
        "-c"
        "/Users/${username}/dotfiles/.config/kanata/kanata.kbd"
        "--port"
        "10000"
        "--debug"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/var/log/kanata.out.log";
      StandardErrorPath = "/var/log/kanata.err.log";
    };
  };

  # Karabiner-VirtualHIDDevice-Daemon (DriverKit pkg は LaunchDaemon 同梱しないので自前)
  launchd.daemons.karabiner-vhiddaemon = {
    serviceConfig = {
      Label = "dev.mei.karabiner-vhiddaemon";
      ProgramArguments = [
        "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
      ];
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
}
