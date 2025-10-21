# Dotfiles

## macOS (Local) Setup

### install

``` bash
git clone https://github.com/mei28/dotfiles.git
cd dotfiles
./setup.sh
```

### nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### home-manager適用（macOS）

```bash
home-manager switch --flake .#mei
```

---

## Remote (EC2/Linux) Setup

リモート環境（EC2インスタンス等）で軽量な開発環境をセットアップします。

### クイックスタート（推奨）

以下のワンコマンドでセットアップが完了します：

```bash
curl -sSL https://raw.githubusercontent.com/mei28/dotfiles/main/remote-bootstrap.sh | bash
```

このスクリプトは以下を自動的に実行します：
1. Nixのインストール
2. dotfilesのクローン
3. home-managerの適用（リモートプロファイル）

セットアップ完了後：
```bash
exec bash  # シェルを再読み込み
tmux       # tmuxセッション開始
```

### 手動セットアップ

```bash
# 1. dotfilesクローン
git clone https://github.com/mei28/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. Nixインストール
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install

# 3. home-manager適用（リモートプロファイル）
nix run home-manager/master -- switch --flake .#mei-remote --impure
```

### 設定の更新

リモート環境で設定を更新する場合：

```bash
cd ~/.dotfiles
git pull
home-manager switch --flake .#mei-remote --impure
```

---

## プロファイル構成

- `mei`: macOS用フルプロファイル（ローカル開発環境）
- `mei-remote`: リモート用軽量プロファイル（EC2/Linux）
  - 自動的に実行ユーザー名を検出（`ubuntu`, `ec2-user`等）
  - 最小限のCLIツール + Neovim/LSP + Tmux/Zellij
  - SSH接続時に自動的にtmuxセッション起動

---

## 含まれるツール

### 共通（base）
- git, gh, fzf, ripgrep, fd, bat, tree, yazi
- neovim, tmux, zellij
- zoxide, jujutsu, gitui

### 開発環境（development）
- LSP: pyright, gopls, rust-analyzer, efm-langserver
- ランタイム: Python(uv), Node.js, Rust, Go, Deno
- ビルドツール: cargo, llvm, sqlite, postgresql

### macOS専用
- karabiner, aerospace, yabai（ウィンドウ管理）
- claude-code, terraform, google-cloud-sdk

---

## Just Commands

便利なタスクランナーコマンド（`just`コマンドが必要）

### ローカル環境（macOS）
```bash
just update-home      # Home Manager設定を適用
just update-darwin    # nix-darwin設定を適用
just update-all       # すべて更新（flake + home + darwin）
just gc               # Nixガベージコレクション
```

### リモート環境
```bash
just remote-apply     # リモートプロファイルを適用
just remote-update    # flake更新 + リモートプロファイル適用
just remote-test      # リモート設定のビルドテスト（dry-run）
```

### 検証とテスト
```bash
just check            # Nix flakeの構文チェック
just fmt              # Nixファイルのフォーマット
just lint-shell       # シェルスクリプトのlint（shellcheck）
just test-docker-ubuntu    # Ubuntu Dockerでテスト
just test-docker-amazon    # Amazon Linux Dockerでテスト
just test-all         # すべてのテストを実行
```

### ユーティリティ
```bash
just info             # 現在の設定情報を表示
just clean            # ビルド成果物をクリーンアップ
```

---

## 検証方法

### 方法1: Docker でのテスト（推奨）

ローカル環境を汚さずにテストできます：

```bash
# Ubuntu環境でテスト
just test-docker-ubuntu

# Amazon Linux環境でテスト
just test-docker-amazon
```

または直接：

```bash
# Ubuntu
docker build -f test/Dockerfile.ubuntu -t dotfiles-test-ubuntu .
docker run --rm -it dotfiles-test-ubuntu

# Amazon Linux
docker build -f test/Dockerfile.amazonlinux -t dotfiles-test-amazon .
docker run --rm -it dotfiles-test-amazon
```

### 方法2: 検証スクリプト

セットアップ後に正しくインストールされたか確認：

```bash
bash test/verify-setup.sh
```

### 方法3: 実際のEC2インスタンス

1. EC2インスタンスを起動（Ubuntu 22.04 または Amazon Linux 2023）
2. SSHで接続
3. Bootstrapスクリプトを実行：
```bash
curl -sSL https://raw.githubusercontent.com/mei28/dotfiles/main/remote-bootstrap.sh | bash
```
4. 検証：
```bash
exec bash
bash ~/.dotfiles/test/verify-setup.sh
```

### CI/CD による自動検証

GitHub Actionsでプッシュ時に自動実行されます：
- Nix flake構文チェック
- シェルスクリプトlint
- プロファイルのビルドテスト（Ubuntu/macOS）

---

## トラブルシューティング

### リモート環境でNixが見つからない
```bash
# シェルを再起動
exec bash

# または新しいシェルセッションを開く
```

### 設定の再適用
```bash
cd ~/.dotfiles
just remote-apply
```

### 完全なクリーンインストール
```bash
rm -rf ~/.dotfiles ~/.local/state/nix/profiles/home-manager
curl -sSL https://raw.githubusercontent.com/mei28/dotfiles/main/remote-bootstrap.sh | bash
```

