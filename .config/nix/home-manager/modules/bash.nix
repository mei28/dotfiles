{ ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      source ~/.config/nix/home-manager/modules/configs/.bashrc
    '';
  };
}
