# HPC Remote Environment Setup

HPC（SuperPOD等）リモートサーバーに、既存のシステム設定を壊さずユーザー環境をデプロイするスクリプト。

nix/home-manager が生成する設定ファイル（tmux, git）をローカルで収集し、
静的ファイル（nvim, bashrc）と合わせてリモートに配置する。

## 前提

- ローカルで home-manager による dotfiles 管理が動作していること
- リモートに SSH 接続できること

## 使い方

### 1. ローカルで nix 生成ファイルを収集

```bash
./remote/hpc-setup.sh collect
```

`remote/generated/` に tmux.conf, gitconfig がコピーされる。

### 2. dotfiles をリモートに転送

```bash
./remote/hpc-setup.sh sync fc1-login-00
```

dotfiles 全体をリモートの `~/dotfiles/` に rsync する。

### 3. リモートで install

```bash
cd ~/dotfiles
./remote/hpc-setup.sh install
source ~/.bashrc
```

install が行うこと:

- `~/.config/nvim` → dotfiles 内の nvim 設定へシンボリンク
- `~/.tmux.conf` → collected tmux.conf へシンボリンク
- `~/.config/git/config` → collected gitconfig へシンボリンク
- `~/.bashrc` に dotfiles の bashrc を source するフックを追記
- TPM（tmux plugin manager）の自動インストール

## ディレクトリ構成

```
remote/
  hpc-setup.sh          # セットアップスクリプト
  generated/            # collect で自動生成（gitignore 対象）
    tmux.conf
    gitconfig
```

## 設定の更新

ローカルで nix 設定を変更した後:

```bash
./remote/hpc-setup.sh collect
./remote/hpc-setup.sh sync fc1-login-00
```

リモート側はシンボリンクなので、ファイルが更新されれば即反映される。

## 注意事項

- tmux の `default-shell` がリモートに存在しない場合、tmux 起動時にエラーが出る可能性がある
- nvim プラグインは初回起動時に lazy.nvim が自動インストールする（ネット接続が必要）
