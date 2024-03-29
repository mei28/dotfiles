sudo apt update 

sudo apt upgrade

sudo apt install -y git curl

git clone https://github.com/pyenv/pyenv.git ~/.pyenv

git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv

sudo apt install python3-venv

sudo apt install rbenv

#setup for nvim
sudo apt-get install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen

cd neovim && make 

sudo make install

cd 

#check temprature
sudo apt install lm-sensors

#deactivate left super
gsettings set org.gnome.mutter overlay-key ''

#add fcitx and fcitx-mozc
sudo apt install fcitx fcitx-mozc -y

#remove ibus
sudo apt purge ibus -y

#add tweak
sudo apt install gnome-tweaks

#gcc
sudo apt-get install build-essential

# change folder name to english
LANG=C xdg-user-dirs-gtk-update

# add trashbox at sidebar
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash true 

# move application top
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true 

# docker
sudo apt install docker docker-compose

# nvidia container toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker

# change rm
cd
git clone https://github.com/andreafrancia/trash-cli
cd trash-cli
sudo python3 setup.py install
cd .. && rm -rf trach-cli

# bash_completion
apt install bash_completion
source /usr/share/bash-completion/bash_completion 

# nodejs
sudo apt install -y nodejs npm n
sudo n stable -g
sudo n stable
sudo apt purge -y nodejs npm
sudo npm install -g neovim

# pbcopy
sudo apt-get install xsel

# openssh
sudo apt-get install openssh-server

# ifconfig 
sudo apt install net-tools

# ffmpeg
sudo apt install ffmpeg

# convert image
sudo apt-get install imagemagick

# tmux
sudo apt-get install tmux

# screen capture
sudo apt install simplescreenrecorder

# powertop
sudo apt install powertop
sudo apt install tlp tlp-rdw

# 
sudo npm install -g tree-sitter-cli
sudo npm install -g tree-sitter

# flat  hub for wezterm
sudo apt install flatpak
sudo apt install gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
sudo apt install ripgrep
sudo apt install bat

sudo apt autoremove


