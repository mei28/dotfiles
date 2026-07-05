# Dotfiles

## アーキテクチャ

三層構造でホストごとの構成を管理:

```
modules/   → 個々の設定 (tmux, bash, git, fzf ...)
profiles/  → 機能グループ (base, development, macos)
hosts/     → 端末ごとの定義 (何を使うかを宣言)
```

### ホスト一覧

| OS | profiles | darwin |
|-----|----------|--------|
| macOS | base + development + macos | あり (brew含む) |
| Linux | base + development | なし |

### 編集ガイド

**パッケージを特定のホストだけに追加したい:**
→ `hosts/<host>.nix` の `home.packages` に追加

```nix
# .config/nix/home-manager/hosts/babalab-mac.nix
home.packages = with pkgs; [
  claude-code
  marp-cli
  # ← ここに追加
];
```

**全ホスト共通のツールを追加したい:**
→ `profiles/base.nix` (CLI基本) or `profiles/development.nix` (開発ツール) に追加

**macOS 固有の symlink や環境変数を追加したい:**
→ `profiles/macos.nix` に追加

**特定ホストで module を除外したい:**
→ そのホストの `hosts/<host>.nix` の `imports` から該当 profile を外す

```nix
# 例: development を入れないホスト
imports = [
  ../profiles/base.nix
  # ../profiles/development.nix  ← コメントアウト
];
```

**Homebrew cask/brew を変更したい:**
→ `nix-darwin/config/homebrew.nix` (共通) を編集。ホスト固有にしたい場合は `nix-darwin/hosts/<host>.nix` に直接書く

**新しい module を作りたい (例: 新ツールの設定):**
→ `modules/<tool>.nix` を作成し、使いたい profile か host の `imports` に追加

### ホストの追加方法

1. `hosts/<new-host>.nix` を作成:

```nix
{ inputs, lib, pkgs, system, ... }:
let
  runtimeUser = builtins.getEnv "USER";
  username = if runtimeUser != "" then runtimeUser else "user";
  homeRoot = if pkgs.stdenv.isDarwin then "/Users" else "/home";
in
{
  imports = [
    ../profiles/base.nix
    ../profiles/development.nix
    # ../profiles/macos.nix  # macOS の場合は追加
  ];

  home.username = username;
  home.homeDirectory = lib.mkDefault "${homeRoot}/${username}";
  home.stateVersion = "25.05";

  # ホスト固有のパッケージ
  home.packages = with pkgs; [];
}
```

2. `flake.nix` に追記:

```nix
homeConfigurations.new-host = home-manager.lib.homeManagerConfiguration {
  pkgs = pkgs;
  extraSpecialArgs = { inherit inputs system; };
  modules = [ ./.config/nix/home-manager/hosts/new-host.nix ];
};
```

3. macOS の場合は `nix-darwin/hosts/<new-host>.nix` も作成し `darwinConfigurations` に追記

4. `justfile` の `info` レシピにホスト情報を追加

5. 適用:

```bash
git add .config/nix/home-manager/hosts/new-host.nix
just build new-host    # ビルド確認
just update new-host   # 適用
```

---

## セットアップ

### macOS

```bash
git clone https://github.com/mei28/dotfiles.git
cd dotfiles
./setup.sh
```

Nix:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

初回適用:

```bash
just bootstrap babalab-mac       # Home Manager
just bootstrap-darwin babalab-mac  # nix-darwin
```

### リモート (EC2/Linux)

ワンコマンド (ホスト名を引数で指定):

```bash
curl -sSL https://raw.githubusercontent.com/mei28/dotfiles/main/remote-bootstrap.sh | bash -s -- qia-aws
```

手動:

```bash
git clone https://github.com/mei28/dotfiles.git ~/dotfiles
cd ~/dotfiles
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
just bootstrap qia-aws  # ホスト名を指定
```

### HPC (sbi-superpod)

Nix/sudo が使えない共有マシン向け。nix 生成ファイルをローカルで収集し、rsync で転送する方式。

```bash
# 1. ローカル: nix 生成ファイルを収集 (tmux.conf, gitconfig)
./remote/hpc-setup.sh collect

# 2. ローカル: dotfiles をリモートに転送
./remote/hpc-setup.sh sync <superpod-host>

# 3. リモート: symlink 配置 + bashrc hook
cd ~/dotfiles
./remote/hpc-setup.sh install
source ~/.bashrc
```

配置されるもの: nvim, tmux.conf, gitconfig, bashrc hook, TPM。
ローカルで nix 設定を変更した場合のみ `collect` + `sync` を再実行。

詳細: [remote/README.md](remote/README.md)

---

## Just Commands

### ホスト操作 (引数にホスト名を指定)

```bash
just update babalab-mac        # Home Manager 適用
just update-darwin babalab-mac # nix-darwin 適用 (macOS のみ)
just update-all babalab-mac    # flake 更新 + home + darwin
just build babalab-mac         # 適用せずビルド確認
just eval babalab-mac          # 構文/参照の高速チェック
just bootstrap babalab-mac     # 初回セットアップ
just bootstrap-darwin babalab-mac  # nix-darwin 初回セットアップ
```

### 共通

```bash
just update-flake         # flake.lock 更新
just gc                   # ガベージコレクション
just delete-old-profiles  # 古い世代を削除
just info                 # ホスト一覧と設定情報
```

### 検証

```bash
just check                # flake 構文チェック
just fmt                  # Nix ファイルのフォーマット
just lint-shell           # shellcheck
just test-docker-ubuntu   # Ubuntu Docker テスト
just test-docker-amazon   # Amazon Linux Docker テスト
just test-all             # 全テスト実行
```

---

## ディレクトリ構成

```
.config/nix/
├── home-manager/
│   ├── hosts/          # 端末ごとの定義
│   │   ├── babalab-mac.nix
│   │   ├── sbi-mac.nix
│   │   ├── qia-aws.nix
│   │   └── sbi-superpod.nix
│   ├── profiles/       # 機能グループ
│   │   ├── base.nix         # CLI 基本 (全ホスト共通)
│   │   ├── development.nix  # 開発ツール (LSP, 言語ランタイム)
│   │   └── macos.nix        # macOS 固有 (symlink, env vars)
│   ├── modules/        # 個々のツール設定
│   │   ├── bash.nix
│   │   ├── git.nix
│   │   ├── tmux.nix
│   │   └── ...
│   └── options.nix     # 共有オプション (git user 等)
└── nix-darwin/
    ├── default.nix     # macOS システム共通設定
    ├── hosts/          # 端末ごとの darwin 設定
    │   ├── babalab-mac.nix
    │   └── sbi-mac.nix
    └── config/         # 個別設定 (fonts, homebrew, system...)
```

---

## 含まれるツール

### 共通 (base)
- CLI: gh, bat, just, fd, ripgrep, dust, delta, tldr, csvlens, miniserve, serie
- ファイル管理: yazi, trash-cli, tree, wget, curl, zip, unzip
- エディタ/セッション: neovim, tmux, tmux-mem-cpu-load
- shell: bash, fzf, zoxide, fastfetch
- VCS: git, gitui, jujutsu

### 開発環境 (development)
- LSP: pyright, gopls, rust-analyzer, efm-langserver, harper
- ランタイム: Python (uv), Node.js (nodejs_24, bun, pnpm, ni, deno), Rust (cargo, rustc), Go, Lua (luajit, luarocks)
- ビルド/フォーマッタ: cargo-generate, llvm, sqlite, postgresql, nixfmt, ruff
- 自作ツール: cliperge, sgh, portsage, bonsai

### macOS (macos profile + darwin)
- symlink: hammerspoon, aerospace, wezterm, ghostty, karabiner, cmux, raycast
- Homebrew cask: aerospace, hammerspoon, wezterm@nightly, ghostty, raycast, marta, azookey, thaw, cmux
- フォント: nerd-fonts.hack, nerd-fonts.symbols-only
- キーリマップ: kanata

---

## 検証方法

### Docker テスト

```bash
just test-docker-ubuntu
just test-docker-amazon
```

### 検証スクリプト

```bash
bash test/verify-setup.sh
```

### EC2 インスタンス

```bash
curl -sSL https://raw.githubusercontent.com/mei28/dotfiles/main/remote-bootstrap.sh | bash -s -- qia-aws
exec bash
bash ~/dotfiles/test/verify-setup.sh
```

---

## トラブルシューティング

### Nix が見つからない
```bash
exec bash
```

### 設定の再適用
```bash
cd ~/dotfiles
just update <host>
```

### 完全なクリーンインストール
```bash
rm -rf ~/dotfiles ~/.local/state/nix/profiles/home-manager
curl -sSL https://raw.githubusercontent.com/mei28/dotfiles/main/remote-bootstrap.sh | bash
```
