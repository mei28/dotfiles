# !/bin/bash
brew install python3
python3 -m venv ~/.venv/neovim
source ~/.venv/neovim/bin/activate
pip install --upgrade pynvim
pip install black flake8 isort
