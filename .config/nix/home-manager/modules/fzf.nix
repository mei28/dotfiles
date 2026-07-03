{ ... }:
{
  programs.fzf = {
    enable = true;

    defaultCommand = "rg --files --hidden --follow --glob '!**/.git/*'";

    defaultOptions = [
      "--height 40%"
      "--reverse"
      "--border=sharp"
      "--margin=0,1"
      "--color=light"
    ];

    fileWidget = {
      command = "rg --files --hidden --follow --glob '!**/.git/*'";
      options = [
        "--preview 'bat --color=always --style=header,grid {}'"
        "--preview-window=right:60%"
      ];
    };

    historyWidget.options = [
      "--preview 'echo {}'"
      "--preview-window=down:3:hidden:wrap"
      "--bind '?:toggle-preview'"
    ];

    enableBashIntegration = true;
    enableZshIntegration = true;
  };
}
