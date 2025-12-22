{ lib, pkgs, ... }:
let
  inherit (import ../options.nix) username gitUsername gitEmail;
  # Deltaが利用可能かチェック
  hasDelta = lib.hasAttr "delta" pkgs;
in
{
  programs.git = {
    enable = true;
    # userName = gitUsername;
    # userEmail = gitEmail;

    attributes = [
      "*.ipynb filter=clean_ipynb"
    ];

    ignores = [
      ".DS_Store"
      "*DS_Store*"
      "node_modules"
      "*.swp"
      ".venv"
      "target"
      ".gardener"
    ];

    settings = {
      user = {
        name = gitUsername;
        email = gitEmail;
      };
      # Core settings
      core.excludesFile = "/Users/${username}/.gitignore_global";
      core.editor = "nvim";
      core.attributesFile = "/Users/${username}/.gitattributes";

      # Diff and merge tool settings
      diff.tool = "nvimdiff";
      difftool.nvimdiff.cmd = "nvim -R -d -c \"wincmd l\" -d \"$LOCAL\" \"$REMOTE\"";
      merge.tool = "nvimdiff";
      mergetool.nvimdiff.cmd = "nvim -d -c \"4wincmd w | wincmd J\" \"$LOCAL\" \"$BASE\" \"$REMOTE\" \"$MERGED\"";
      mergetool.keepBackup = "false";

      # Other Git settings
      init.defaultBranch = "main";
      credential.helper = "store";
      fetch.prune = "true";
      pull.ff = "only";
      pull.rebase = "false";
      pull.autostash = "true";
      rebase.autoStash = "true";
      rebase.autoSquash = "true";

      # Legacy pager settings (fallback when delta is not available)
      # pager.log = "diff-highlight | less";
      # pager.show = "diff-highlight | less";
      # pager.diff = "diff-highlight | less";

      # Delta pager settings
      core.pager = if hasDelta then "delta" else "diff-highlight | less";
      interactive.diffFilter = lib.mkIf hasDelta "delta --color-only";

      # Delta basic options
      delta = lib.mkIf hasDelta {
        navigate = true;
        dark = true;
        syntax-theme = "Monokai Extended";
        line-numbers = true;
        side-by-side = true;
      };

      # Aliases
      alias.lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      alias.lga = "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      alias.fixup = "commit --amend -C HEAD";
      alias.lgf = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative --";
      alias.lgaf = "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative --";

      # Delta toggle aliases
      alias.ds = "!git -c delta.side-by-side=true diff";
      alias.dln = "!git -c delta.features='line-numbers' diff";
      alias.dss = "!git -c delta.features='side-by-side line-numbers' diff";
      alias.ss = "!git -c delta.side-by-side=true show";
      alias.lgs = "!git -c delta.side-by-side=true log -p";

      # Delta named features for toggling
      "delta \"line-numbers\"" = lib.mkIf hasDelta {
        line-numbers = true;
        line-numbers-left-style = "cyan";
        line-numbers-right-style = "cyan";
        line-numbers-minus-style = "124";
        line-numbers-plus-style = "28";
      };

      "delta \"side-by-side\"" = lib.mkIf hasDelta {
        side-by-side = true;
        line-numbers = true;
      };

      "delta \"decorations\"" = lib.mkIf hasDelta {
        commit-decoration-style = "blue ol";
        commit-style = "raw";
        file-style = "omit";
        hunk-header-decoration-style = "blue box";
        hunk-header-file-style = "red";
        hunk-header-line-number-style = "#067a00";
        hunk-header-style = "file line-number syntax";
      };

      # Filter for cleaning Jupyter notebooks
      filter.clean_ipynb.clean = "jq --indent 1 --monochrome-output '. + if .metadata.git.suppress_outputs | not then { cells: [.cells[] | . + if .cell_type == \"code\" then { outputs: [], execution_count: null } else {} end ] } else {} end'";
      filter.clean_ipynb.smudge = "cat";
    };
  };
}
