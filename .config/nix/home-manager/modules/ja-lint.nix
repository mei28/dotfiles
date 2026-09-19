# Japanese prose lint toolchain for the japanese-tech-writing skill.
# ~/.claude/skills/japanese-tech-writing/scripts/lint.sh resolves these from PATH:
#   suiko     translationese, repetition, rhythm, reading load
#   textlint  bundled with preset-ai-words-ja and preset-ai-writing (see pkgs/textlint-ja)
#   pandoc    converts .tex input to Markdown before linting
{ pkgs, ... }:
{
  home.packages = [
    (pkgs.callPackage ../../pkgs/suiko.nix { })
    (pkgs.callPackage ../../pkgs/textlint-ja { })
    pkgs.pandoc
  ];
}
