{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.ssh.enable = true;

  # グローバルなSSHオプションは programs.ssh のトップレベルに配置します
  # matchBlocks."*" に書くのではなく、programs.ssh の直下です
  programs.ssh.controlMaster = "auto";
  programs.ssh.controlPath = "~/.ssh/mux-%r@%h:%p";
  programs.ssh.controlPersist = "4h";

  programs.ssh.matchBlocks = {
    # HomeUbuntu
    HomeUbuntu = {
      hostname = "192.168.40.30";
      user = "mei";
      port = 22;
      # GatewayPorts も extraOptions で設定します
      extraOptions = {
        GatewayPorts = "yes";
      };
      # localForward は localForwards (複数形) を使い、複雑な属性セットのリストで指定します
      localForwards = [
        {
          bind.port = 8888;
          host.address = "localhost";
          host.port = 8888;
        }
        {
          bind.port = 9096;
          host.address = "localhost";
          host.port = 9096;
        }
      ];
      identityFile = "~/.ssh/id_rsa";
    };

    # RaspberryPi
    RaspberryPi = {
      hostname = "raspberrypi.local";
      user = "pi";
      identityFile = "~/.ssh/id_rsa";
    };

    # TailUbuntu
    TailUbuntu = {
      hostname = "100.84.33.5";
      user = "mei";
      identityFile = "~/.ssh/id_rsa";
      localForwards = [
        {
          bind.port = 9096;
          host.address = "localhost";
          host.port = 9096;
        }
      ];
    };

    # TailBabalab
    TailBabalab = {
      hostname = "100.112.158.106";
      user = "babalab";
      identityFile = "~/.ssh/id_rsa";
      localForwards = [
        {
          bind.port = 8888;
          host.address = "localhost";
          host.port = 8888;
        }
        {
          bind.port = 9096;
          host.address = "localhost";
          host.port = 9096;
        }
        {
          bind.port = 5173;
          host.address = "localhost";
          host.port = 5173;
        }
        {
          bind.port = 4040;
          host.address = "localhost";
          host.port = 4040;
        }
      ];
    };

    # github と github.com
    # Host github github.com は、Home ManagerのmatchBlocksのキーとして "github" を使い、
    # Hostname は "github.com" とします。
    # github.com のエイリアスとして使いたい場合は、別途 "github.com" の matchBlock を定義するか、
    # ユーザーが ssh github.com とタイプした時にうまくいくようにする必要があります。
    # 多くのSSHクライアントは HostName があれば Host エイリアスは最初のものだけで十分です。
    github = {
      hostname = "github.com";
      user = "git";
      identityFile = "~/.ssh/id_git_rsa";
    };
    # github.com も直接使いたい場合は、別途定義
    # github.com = {
    #   hostname = "github.com";
    #   user = "git";
    #   identityFile = "~/.ssh/id_git_rsa";
    # };

    # ec2-rag
    "ec2-rag" = {
      # ハイフンを含む場合はクォートで囲む
      hostname = "15.168.113.47";
      user = "ubuntu";
      identityFile = "~/.ssh/eggai.pem";
      localForwards = [
        {
          bind.port = 8000;
          host.address = "localhost";
          host.port = 8000;
        }
      ];
    };

    # もし Moonshot プロジェクト用の新しい設定を追加するならここ
    # moonshot = {
    #   hostname = "your_moonshot_server_hostname.com";
    #   user = "your_moonshot_username";
    #   identityFile = "~/.ssh/id_moonshot";
    #   port = 22;
    #   # strictHostKeyChecking と userKnownHostsFile も extraOptions で設定することが多いです
    #   # 例えば:
    #   # extraOptions = {
    #   #   StrictHostKeyChecking = "no";
    #   #   UserKnownHostsFile = "/dev/null";
    #   # };
    # };
  };
}
