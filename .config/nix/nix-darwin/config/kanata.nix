{ username, ... }:
let
  # HRM のチャタリング調査中は false にしておく。
  # false のまま darwin-rebuild switch すると LaunchDaemon の plist ごと消えるため、
  # 再起動しても kanata は起動しない。HRM を使う状態に戻すときは true にして switch する。
  # homebrew の kanata 本体と sudoers はこのフラグに関係なく残す (手動起動と切り分けのため)。
  enableKanata = false;
in
{
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

  launchd.daemons = (
    if enableKanata then
      {
        kanata-internal = {
          serviceConfig = {
            Label = "dev.mei.kanata-internal";
            # --debug は付けない。1 キーイベントあたり約 13.7 行 / 2KB を StandardOutPath へ
            # 同期書き込みするため、ログが 1.4GB まで育ち処理スレッドが最大 495ms 停止した。
            # Release の送出が遅れると macOS 側がキー押しっぱなしと解釈してオートリピートが
            # 暴発する (= チャタリングに見える)。切り分けで必要なときだけ一時的に付け、
            # 出力先も /tmp に逃がすこと。
            ProgramArguments = [
              "/opt/homebrew/bin/kanata"
              "-c"
              "/Users/${username}/dotfiles/.config/kanata/kanata.kbd"
              "--port"
              "10000"
            ];
            RunAtLoad = true;
            KeepAlive = true;
            StandardOutPath = "/var/log/kanata.out.log";
            StandardErrorPath = "/var/log/kanata.err.log";
          };
        };
      }
    else
      { }
  )
  // {
    # Karabiner-VirtualHIDDevice-Daemon (DriverKit pkg は LaunchDaemon 同梱しないので自前)
    karabiner-vhiddaemon = {
      serviceConfig = {
        Label = "dev.mei.karabiner-vhiddaemon";
        ProgramArguments = [
          "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
        ];
        RunAtLoad = true;
        KeepAlive = true;
      };
    };
  };
}
