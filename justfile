# Justfile

# シェル設定: bash を利用し、エラー検知を強化
set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# ユーザー名などを変数化
username := "mei"
darwinHost := "mei-darwin"

# -------------------------------------------------------
# 1) フレーク更新だけを行うタスク
# -------------------------------------------------------
update-flake:
  @echo "Updating flake..."
  nix flake update

# -------------------------------------------------------
# 2) Home Manager 更新だけを行うタスク
# -------------------------------------------------------
update-home:
  @echo "Updating Home Manager config..."
  nix run nixpkgs#home-manager -- switch --flake .#{{username}}

# -------------------------------------------------------
# 3) nix-darwin 更新だけを行うタスク
# -------------------------------------------------------
update-darwin:
  @echo "Updating nix-darwin config..."
  nix run nix-darwin -- switch --flake .#{{darwinHost}}

# -------------------------------------------------------
# 4) すべてまとめて更新 (必要なら)
# -------------------------------------------------------
# 依存タスクとして指定すれば、順番に実行されます
update-all: update-flake update-home update-darwin

# -------------------------------------------------------
# デフォルトタスク (使わないなら消してもOK)
# -------------------------------------------------------
default:
  @echo "Available tasks:"
  @echo "  just update-flake"
  @echo "  just update-home"
  @echo "  just update-darwin"
  @echo "  just update-all (runs all tasks in sequence)"

