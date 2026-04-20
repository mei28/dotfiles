{
  nix = {
    enable = false;
    settings = {
      experimental-features = "nix-command flakes";
      max-jobs = 8;
    };
  };

  # Determinate owns /etc/nix/nix.conf, so substituters must go via its !include nix.custom.conf.
  environment.etc."nix/nix.custom.conf".text = ''
    extra-substituters = https://nix-community.cachix.org
    extra-trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
  '';
}
