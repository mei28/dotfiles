{ ... }:
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "mei";
        email = "mei28aquarius@gmail.com";
      };
      ui = {
        editor = "nvim";
      };
    };
  };
}
