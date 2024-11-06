{ pkgs, ... }:
{
  programs.bash = {
    enable = true;
  };

  home.file = {
    ".bashrc".source = "/Users/mei/.bashrc";
    ".profile".source = "/Users/mei/.profile";
    ".bash_profile".source = "/Users/mei/.bash_profile";
  };
}

