{ ... }:
let
  inherit (import ../options.nix) gitUsername gitEmail;
in
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = gitUsername;
        email = gitEmail;
      };
      ui = {
        editor = "nvim";
      };
    };
  };
}
