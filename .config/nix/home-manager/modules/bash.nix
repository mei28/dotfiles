{ ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellOptions = [ ];
    bashrcExtra = ''
      source ~/.config/nix/home-manager/modules/configs/.bashrc
    '';
  };
}
