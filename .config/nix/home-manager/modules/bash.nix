{ ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      # Source custom bashrc from dotfiles directory
      if [ -f ~/dotfiles/.config/nix/home-manager/modules/configs/.bashrc ]; then
        source ~/dotfiles/.config/nix/home-manager/modules/configs/.bashrc
      fi
    '';
  };
}
