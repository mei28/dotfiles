{ pkgs }: {
  fonts.packages = with pkgs; [
    hackgen-font
    hackgen-nf-font
    nerd-fonts.hack
    nerd-fonts.symbols-only
    font-awesome
    font-awesome_5
  ];
}
