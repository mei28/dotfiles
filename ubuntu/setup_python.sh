# !/bin/bash

sudo apt install python3-venv
python3 -m venv ~/.venv/neovim
source ~/.venv/neovim/bin/activate
pip install --upgrade pynvim
pip install black flake8 isort
