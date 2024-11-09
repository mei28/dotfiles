{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.fzf;
in
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

    fileWidgetCommand = "rg --files --hidden --follow --glob '!**/.git/*'";

    fileWidgetOptions = [
      "--preview 'bat --color=always --style=header,grid {}'"
      "--preview-window=right:60%"
    ];

    historyWidgetOptions = [
      "--preview 'echo {}'"
      "--preview-window=down:3:hidden:wrap"
      "--bind '?:toggle-preview'"
    ];

    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  home.sessionVariables = lib.filterAttrs (k: v: v != null && v != [ ]) {
    FZF_ALT_C_COMMAND = cfg.changeDirWidgetCommand;
    FZF_ALT_C_OPTS = lib.concatStringsSep " " cfg.changeDirWidgetOptions;
    FZF_CTRL_R_OPTS = lib.concatStringsSep " " cfg.historyWidgetOptions;
    FZF_CTRL_T_COMMAND = cfg.fileWidgetCommand;
    FZF_CTRL_T_OPTS = lib.concatStringsSep " " cfg.fileWidgetOptions;
    FZF_DEFAULT_COMMAND = cfg.defaultCommand;
    FZF_DEFAULT_OPTS = lib.concatStringsSep " " cfg.defaultOptions;
  };
}
