{ ... }:

{
  programs.fzf = {
    enable = true;

    # パス設定
    defaultCommand = "rg --files --hidden --follow --glob '!**/.git/*'";

    defaultOptions = [
      "--height" "40%"
      "--reverse"
      "--border=sharp"
      "--margin=0,1"
      "--color=light"
    ];

    # CTRL+T キーバインディングの設定
    fileWidgetCommand = "rg --files --hidden --follow --glob '!**/.git/*'";

    fileWidgetOptions = [
      "--preview" "bat --color=always --style=header,grid {}"
      "--preview-window=right:60%"
    ];

    # CTRL+R キーバインディングの設定
    historyWidgetOptions = [
      "--preview" "echo {}"
      "--preview-window=down:3:hidden:wrap"
      "--bind" "?:toggle-preview"
    ];

    # Bash および Zsh 用の統合を有効化
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
}
