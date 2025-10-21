{ ... }:
let
  inherit (import ../options.nix) username gitUsername gitEmail;
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

      # Pager settings
      pager.log = "diff-highlight | less";
      pager.show = "diff-highlight | less";
      pager.diff = "diff-highlight | less";

      # Aliases
      alias.lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      alias.lga = "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      alias.fixup = "commit --amend -C HEAD";
      alias.lgf = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative --";
      alias.lgaf = "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative --";

      # Filter for cleaning Jupyter notebooks
      filter.clean_ipynb.clean = "jq --indent 1 --monochrome-output '. + if .metadata.git.suppress_outputs | not then { cells: [.cells[] | . + if .cell_type == \"code\" then { outputs: [], execution_count: null } else {} end ] } else {} end'";
      filter.clean_ipynb.smudge = "cat";
    };
  };
}
