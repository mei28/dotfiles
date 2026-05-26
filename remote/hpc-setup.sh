#!/bin/bash
# ==============================================================================
# hpc-setup.sh
#
# HPC（SuperPOD等）リモートサーバーに、既存のシステム設定を壊さず
# 使い慣れたユーザー環境をデプロイする。
#
# 使い方:
#   ローカル: ./remote/hpc-setup.sh collect   ← nix 生成ファイルを収集
#   リモート: ./remote/hpc-setup.sh install   ← シンボリンク配置 + bashrc hook
# ==============================================================================

set -euo pipefail

C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_CYAN='\033[0;36m'
C_RED='\033[0;31m'
C_RESET='\033[0m'

log_info()    { echo -e "${C_CYAN}[INFO]${C_RESET}  $1"; }
log_success() { echo -e "${C_GREEN}[OK]${C_RESET}    $1"; }
log_warn()    { echo -e "${C_YELLOW}[WARN]${C_RESET}  $1"; }
log_error()   { echo -e "${C_RED}[ERROR]${C_RESET} $1"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REMOTE_DIR="$DOTFILES_DIR/remote"
GENERATED_DIR="$REMOTE_DIR/generated"

# ------------------------------------------------------------------------------
# collect: ローカルで実行。nix/home-manager が生成した設定ファイルを収集
# ------------------------------------------------------------------------------
cmd_collect() {
    log_info "Collecting nix-generated config files..."
    mkdir -p "$GENERATED_DIR"

    # tmux.conf: home-manager が生成した実体をコピー
    local tmux_src="$HOME/.config/tmux/tmux.conf"
    if [ -f "$tmux_src" ]; then
        cp -L "$tmux_src" "$GENERATED_DIR/tmux.conf"
        log_success "tmux.conf"
    else
        log_warn "tmux.conf not found at $tmux_src"
    fi

    # gitconfig: home-manager が生成した実体をコピー
    # home-manager は ~/.config/git/config に生成する
    local git_src="$HOME/.config/git/config"
    if [ -f "$git_src" ]; then
        cp -L "$git_src" "$GENERATED_DIR/gitconfig"
        log_success "gitconfig"
    else
        log_warn "gitconfig not found at $git_src"
    fi

    echo "---"
    log_success "Collected to: $GENERATED_DIR"
    log_info "Commit these files, then push/rsync dotfiles to remote."
}

# ------------------------------------------------------------------------------
# install: リモートで実行。シンボリンク配置 + bashrc hook 注入
# ------------------------------------------------------------------------------
cmd_install() {
    log_info "Installing dotfiles for HPC environment..."
    log_info "Dotfiles directory: $DOTFILES_DIR"

    # generated/ の存在確認
    if [ ! -d "$GENERATED_DIR" ]; then
        log_error "generated/ directory not found. Run 'hpc-setup.sh collect' on local first."
        exit 1
    fi

    # --- symlinks ---
    echo "--- Creating Symlinks ---"
    mkdir -p ~/.config

    deploy_symlink() {
        local src="$1"
        local dest="$2"
        local label="$3"

        if [ -e "$src" ]; then
            ln -snf "$src" "$dest"
            log_success "$label -> $dest"
        else
            log_warn "$label: source not found ($src). Skipped."
        fi
    }

    # nvim: 静的ファイル、そのままリンク
    deploy_symlink "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim" "nvim"

    # tmux: nix 生成 → collected copy
    deploy_symlink "$GENERATED_DIR/tmux.conf" "$HOME/.tmux.conf" "tmux"

    # git: nix 生成 → collected copy
    mkdir -p "$HOME/.config/git"
    deploy_symlink "$GENERATED_DIR/gitconfig" "$HOME/.config/git/config" "gitconfig"

    # --- bashrc hook ---
    echo "--- Injecting bashrc hook ---"

    local bashrc_source="$DOTFILES_DIR/.config/nix/home-manager/modules/configs/.bashrc"
    if [ ! -f "$bashrc_source" ]; then
        log_error "bashrc source not found: $bashrc_source"
        exit 1
    fi

    local marker="# >>> [hpc-setup] dotfiles >>>"
    if [ -f "$HOME/.bashrc" ] && grep -qF "$marker" "$HOME/.bashrc"; then
        log_info "bashrc hook already present. Skipped."
    else
        cat <<EOF >> "$HOME/.bashrc"

$marker
if [ -f "$bashrc_source" ]; then
  source "$bashrc_source"
fi
# <<< [hpc-setup] dotfiles <<<
EOF
        log_success "bashrc hook injected"
    fi

    # --- TPM (tmux plugin manager) ---
    echo "--- tmux plugin manager ---"
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        log_info "Installing TPM..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        log_success "TPM installed"
    else
        log_info "TPM already installed. Skipped."
    fi

    # --- 完了 ---
    echo "---"
    log_success "HPC environment setup complete!"
    log_info "Run: source ~/.bashrc"
}

# ------------------------------------------------------------------------------
# usage
# ------------------------------------------------------------------------------
cmd_usage() {
    echo "Usage: $(basename "$0") <command>"
    echo ""
    echo "Commands:"
    echo "  collect   Collect nix-generated configs (run on local machine)"
    echo "  install   Deploy dotfiles to HPC (run on remote machine)"
}

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
case "${1:-}" in
    collect) cmd_collect ;;
    install) cmd_install ;;
    *)       cmd_usage; exit 1 ;;
esac
