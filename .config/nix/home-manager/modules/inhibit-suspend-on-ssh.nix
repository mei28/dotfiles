# Hold a GNOME suspend inhibitor while an SSH session is open, so the desktop's
# idle auto-suspend (sleep-inactive-ac-type) does not cut a remote session off.
# logind's block inhibitor is refused by polkit for remote sessions, so this goes
# through gnome-session on the user bus instead, which is what gsd-power consults
# before suspending. Needs a running GNOME session; loginctl and
# gnome-session-inhibit come from the host OS, not nix.
{ pkgs, ... }:
let
  inhibit-suspend-on-ssh = pkgs.writeShellApplication {
    name = "inhibit-suspend-on-ssh";
    text = ''
      poll_seconds=30

      has_ssh_session() {
        local id props
        for id in $(loginctl list-sessions --no-legend | awk '{ print $1 }'); do
          props=$(loginctl show-session "$id" --property=Remote --property=State)
          if grep -qx 'Remote=yes' <<<"$props" && grep -qx 'State=active' <<<"$props"; then
            return 0
          fi
        done
        return 1
      }

      # Run under gnome-session-inhibit: stay alive while a session is open,
      # then exit so the parent loop releases the inhibitor.
      if [ "''${1:-}" = "--hold" ]; then
        while has_ssh_session; do
          sleep "$poll_seconds"
        done
        exit 0
      fi

      while true; do
        if has_ssh_session; then
          gnome-session-inhibit --inhibit suspend --reason "SSH session active" "$0" --hold
        fi
        sleep "$poll_seconds"
      done
    '';
  };
in
{
  systemd.user.services.inhibit-suspend-on-ssh = {
    Unit = {
      Description = "Inhibit GNOME auto-suspend while SSH sessions are active";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${inhibit-suspend-on-ssh}/bin/inhibit-suspend-on-ssh";
      Restart = "on-failure";
      RestartSec = 10;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
