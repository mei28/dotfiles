{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.ssh.enable = true;
  programs.ssh.enableDefaultConfig = false; # デフォルト設定を無効化

  # settings は OpenSSH ディレクティブ名 (大文字始まり) を直接使う
  programs.ssh.settings = {
    "*" = {
      ControlMaster = "auto";
      ControlPath = "~/.ssh/mux-%r@%h:%p";
      ControlPersist = "4h";
      ServerAliveInterval = 60;
      ServerAliveCountMax = 120;
    };

    # HomeUbuntu
    HomeUbuntu = {
      HostName = "192.168.40.30";
      User = "mei";
      Port = 22;
      GatewayPorts = "yes";
      LocalForward = [
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
      IdentityFile = "~/.ssh/id_rsa";
    };

    # RaspberryPi
    RaspberryPi = {
      HostName = "raspberrypi.local";
      User = "pi";
      IdentityFile = "~/.ssh/id_rsa";
    };

    # TailUbuntu
    TailUbuntu = {
      HostName = "100.84.33.5";
      User = "mei";
      IdentityFile = "~/.ssh/id_rsa";
      LocalForward = [
        {
          bind.port = 9096;
          host.address = "localhost";
          host.port = 9096;
        }
      ];
    };

    # TailBabalab
    TailBabalab = {
      HostName = "100.112.158.106";
      User = "babalab";
      IdentityFile = "~/.ssh/id_rsa";
      LocalForward = [
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

    # github
    github = {
      HostName = "github.com";
      User = "git";
      IdentityFile = "~/.ssh/id_git_rsa";
    };

    # ec2-rag
    "ec2-rag" = {
      HostName = "15.168.113.47";
      User = "ubuntu";
      IdentityFile = "~/.ssh/eggai.pem";
      LocalForward = [
        {
          bind.port = 8000;
          host.address = "localhost";
          host.port = 8000;
        }
      ];
    };

    # 外側 (踏み台) as-highreso
    "as-highreso" = {
      HostName = "as-highreso.com";
      Port = 30022;
      User = "user";
      IdentityFile = "~/.ssh/ackey.txt";
    };

    # 内側 (SOROBAN サーバ)
    "soroban" = {
      HostName = "172.30.35.52";
      Port = 10022;
      User = "yang";
      IdentityFile = "~/.ssh/id_moonshot_rsa";
      ProxyJump = "as-highreso";
    };
  };
}
