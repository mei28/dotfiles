{ pkgs, ... }:
{
  home.packages = [
    pkgs.claude-code
  ];

  home.sessionVariables = {
    CLAUDE_CODE_EFFORT_LEVEL = "max";
  };
}
