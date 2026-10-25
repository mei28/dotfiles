# Mask GNOME's ibus-daemon unit on a host whose input method is fcitx5.
# fcitx5's IBus frontend already owns org.freedesktop.IBus on the session bus,
# so the vendor unit exits with "current session already has an ibus-daemon" on
# every login and leaves the user systemd session degraded, which hides real
# unit failures. Linking the unit name to /dev/null is what `systemctl --user
# mask` does; home-manager has no mask option, so declare the link directly.
# Unmask (drop this module) before switching the host back to IBus.
{ config, ... }:
{
  xdg.configFile."systemd/user/org.freedesktop.IBus.session.GNOME.service".source =
    config.lib.file.mkOutOfStoreSymlink "/dev/null";
}
