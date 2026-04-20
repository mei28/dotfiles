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

### 設定の適用（macOS）

ユーザー設定（home-manager）とシステム設定（nix-darwin）を別々に適用します。

```bash
# ユーザー設定（CLI ツール、shell、neovim 等）
just update-home

# システム設定（/etc, launchd, homebrew, フォント等）— root 必要
sudo just update-darwin

# まとめて: flake 更新 + home + darwin
just update-all
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
git clone https://github.com/mei28/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Nixインストール
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install

# 3. home-manager適用（リモートプロファイル）
nix run home-manager/master -- switch --flake .#mei-remote --impure
```

### 設定の更新

リモート環境で設定を更新する場合：

```bash
cd ~/dotfiles
git pull
home-manager switch --flake .#mei-remote --impure
```

---

## プロファイル構成

home-manager:
- `mei`: macOS 用フルプロファイル（ローカル開発環境）
- `mei-remote`: リモート用軽量プロファイル（EC2/Linux）
  - 自動的に実行ユーザー名を検出（`ubuntu`, `ec2-user` 等）
  - 最小限の CLI ツール + Neovim/LSP + Tmux
  - SSH 接続時に自動的に tmux セッション起動

nix-darwin:
- `mei-darwin`: macOS システム設定（`/etc`、launchd、homebrew、フォント等）

---

## 含まれるツール

実体は `.config/nix/home-manager/profiles/{base,development,macos,remote}.nix` と `.config/nix/nix-darwin/config/homebrew.nix` を参照。

### 共通（base / 全プロファイル）
- CLI: gh, bat, just, fd, ripgrep, dust, delta, tldr, csvlens, miniserve, serie
- ファイル管理: yazi, trash-cli, tree, wget, curl, zip, unzip
- エディタ/セッション: neovim, tmux, tmux-mem-cpu-load
- shell 補助 (programs.* 経由): bash, fzf, zoxide, fastfetch
- VCS: git, gitui, jujutsu

### 開発環境（development / mei・mei-remote）
- LSP: pyright, gopls, rust-analyzer, efm-langserver
- ランタイム: Python (uv), Node.js (nodejs_24, bun, pnpm, ni, deno), Rust (cargo, rustc), Go, Lua (luajit, luarocks)
- ビルド/フォーマッタ: cargo-generate, llvm, sqlite, postgresql, nixfmt-rfc-style, ruff
- 自作ツール: cliperge, sgh, portsage, git-gardener, bonsai

### macOS 専用 (`mei` プロファイル)
- メディア: ffmpeg, ffmpegthumbnailer, imagemagick, ghostscript, marp-cli
- クラウド/IaC: google-cloud-sdk, terraform, heroku
- その他: claude-code, tree-sitter, git-lfs, openssl, arxiv-latex-cleaner

### macOS システム (`mei-darwin` / homebrew 経由)
- ウィンドウ管理: aerospace, hammerspoon
- ターミナル: wezterm, wezterm@nightly, ghostty
- ランチャー/ユーティリティ: raycast, marta, ngrok, azookey, thaw
- フォント: font-hack-nerd-font, font-symbols-only-nerd-font

---

## Just Commands

便利なタスクランナーコマンド（`just`コマンドが必要）

### ローカル環境（macOS）
```bash
just update-home      # Home Manager 設定を適用
just update-darwin    # nix-darwin 設定を適用（root 必要 → sudo 経由で呼ぶ）
just update-flake     # flake.lock を更新
just update-all       # すべて更新（flake + home + darwin）
just build-home       # 適用せずビルドだけ（事前検証）
just eval-home        # 構文/参照のみ評価（高速チェック）
just gc               # Nix ガベージコレクション
just delete-old-profiles  # 古い世代を削除
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
bash ~/dotfiles/test/verify-setup.sh
```

### CI/CD による自動検証

`.github/workflows/ci.yml` で push / PR 時に自動実行:
- `nix flake check --impure` と nixfmt フォーマットチェック
- `shellcheck` (`remote-bootstrap.sh`, `test/verify-setup.sh`)
- `mei-remote` プロファイルのビルド（ubuntu-latest）
- `remote-bootstrap.sh` の構文 + 必須コマンド検査

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
cd ~/dotfiles
just remote-apply
```

### 完全なクリーンインストール
```bash
rm -rf ~/dotfiles ~/.local/state/nix/profiles/home-manager
curl -sSL https://raw.githubusercontent.com/mei28/dotfiles/main/remote-bootstrap.sh | bash
```

