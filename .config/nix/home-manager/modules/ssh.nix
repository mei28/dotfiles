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
    # === 新しい設定: 2段階SSHトンネルの再現 ===
    # 1. 踏み台サーバーへの接続とローカルポートフォワーディング (ターミナル1の役割)
    # この設定を使用するには `ssh as-highreso-tunnel` のように直接実行する必要があります。
    # -g オプションは localForwards の bind.address で "0.0.0.0" を指定することで再現できます。
    "as-highreso-tunnel" = {
      # 新しいエイリアス名を付けます
      hostname = "as-highreso.com";
      user = "user"; # as-highreso.com へのログインユーザー名
      port = 30022; # as-highreso.com へのSSHポート
      identityFile = "~/.ssh/ackey.txt"; # as-highreso.com へのログインに使用する鍵
      localForwards = [
        {
          # -g (GatewayPorts) に対応するため、bind.address を "0.0.0.0" に設定
          bind.address = "0.0.0.0";
          bind.port = 10022;
          host.address = "172.30.35.52"; # 最終目的サーバーのIPアドレス
          host.port = 10022; # 最終目的サーバーのSSHポート
        }
      ];
      # 必要であれば、以下を追加して接続が閉じないようにする
      # serverAliveInterval = 60;
      # serverAliveCountMax = 5;
    };

    # 2. 最終目的サーバーへの接続 (ターミナル2の役割)
    # この設定は、上記で確立されたローカルポートフォワーディングに対して接続します。
    "soroban-target" = {
      # 新しいエイリアス名を付けます
      hostname = "localhost"; # トンネルのローカルエンドポイント
      user = "yang"; # 最終目的サーバーへのログインユーザー名
      port = 10022; # ローカルでフォワードされたポート
      identityFile = "~/.ssh/id_moonshot_rsa"; # 最終目的サーバーへのログインに使用する鍵
      # 注意: Home Manager の programs.ssh はデフォルトで StrictHostKeyChecking が有効です。
      # 必要であれば extraOptions で "StrictHostKeyChecking = no;" を追加できますが、
      # セキュリティ上の理由から推奨されません。
      # ExtraOptions = {
      #   StrictHostKeyChecking = "no";
      #   UserKnownHostsFile = "/dev/null";
      # };
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
