{ pkgs, ... }:
let
  mutagenYml = pkgs.writeText "mutagen.yml" ''
    sync:
      defaults:
        mode: "two-way-resolved"
        watch:
          pollingInterval: 5
        ignore:
          vcs: true
          paths:
            - ".DS_Store"
            - "node_modules/"
            - ".venv/"
            - "__pycache__/"
            - "*.pyc"
            - ".direnv/"
            - "result"
            - ".devenv/"
        permissions:
          defaultFileMode: "0644"
          defaultDirectoryMode: "0755"

    forward:
      defaults:
        socket:
          overwriteMode: "overwrite"
  '';
in
{
  home.packages = with pkgs; [
    mutagen
    mutagen-compose
  ];

  xdg.configFile."mutagen/mutagen.yml".source = mutagenYml;

  programs.bash.shellAliases = {
    msync = "mutagen sync list";
    mfwd = "mutagen forward list";
    mmon = "mutagen sync monitor";
  };
}
