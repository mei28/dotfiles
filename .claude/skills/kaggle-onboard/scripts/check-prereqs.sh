#!/usr/bin/env bash
# Check what kaggle-onboard needs before it starts. Prints the fix for each missing item; exits 1 if any.
set -u

missing=0

if ! command -v kaggle >/dev/null 2>&1 && ! command -v uv >/dev/null 2>&1; then
  echo "kaggle CLI: not found. Install it (uv adds it to the template's dev group)."
  missing=1
elif ! kaggle competitions submissions -c titanic >/dev/null 2>&1 && ! uv run --with kaggle kaggle competitions submissions -c titanic >/dev/null 2>&1; then
  echo "kaggle CLI: not authenticated. Run: kaggle auth login  (or set KAGGLE_API_TOKEN / ~/.kaggle/access_token)"
  missing=1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "gh: not authenticated. Run: gh auth login  (or gh auth refresh -h github.com)"
  missing=1
fi

# The plugin reads KAGGLE_API_TOKEN from the environment or from .env in the competition repo (cwd).
if [ -z "${KAGGLE_API_TOKEN:-}" ] && ! { [ -f .env ] && grep -q '^KAGGLE_API_TOKEN=.\+' .env; }; then
  echo "KAGGLE_API_TOKEN: not set. Inside a competition repo run: just kaggle-token  (copies the OAuth access token into .env; valid a few hours). A long-lived token from https://www.kaggle.com/settings/api in ~/.bashrc.local also works."
  missing=1
fi

if command -v claude >/dev/null 2>&1; then
  if ! claude plugin list 2>/dev/null | grep -q "nvidia-kaggle@nvidia-kaggle"; then
    echo "nvidia-kaggle plugin: not installed. Run: just -f ~/dotfiles/justfile setup-claude-plugins"
    missing=1
  fi
else
  echo "claude CLI: not found; cannot verify the nvidia-kaggle plugin. Install it for this runtime by hand (see https://github.com/NVIDIA/nvidia-kaggle)."
  missing=1
fi

if [ "$missing" -eq 0 ]; then
  echo "prerequisites ok"
fi
exit "$missing"
