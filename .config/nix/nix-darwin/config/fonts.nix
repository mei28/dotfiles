{pkgs}: {
  fonts.packages = with pkgs; [
    hackgen-font
    hackgen-nf-font
    # nerd-fonts
    font-awesome
    font-awesome_5
  ];
}
