#!/usr/bin/env bash

[ -z "${HOME}" ] && echo "\$HOME not specified" && exit 1
[ -z "${EMAIL}" ] && echo "\$EMAIL not specified" && exit 1

flatpak update

# Set to use local time and not utc
timedatectl set-local-rtc 1 --adjust-system-clock

sudo apt-add-repository ppa:git-core/ppa -y
sudo apt update -y ; sudo apt upgrade -y

mkdir -p $HOME/git
mkdir -p $HOME/.bin

## Apt
. ./install-scripts/apt.bash

## Browsers
. ./install-scripts/browsers.bash

## DOCKER
. ./install-scripts/docker.bash

## Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

## Alacritty: Make sure undercurl works
curl -sSL https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info | tic -x -

## Yubikey
sudo wget -O /etc/udev/rules.d/70-u2f.rules https://raw.githubusercontent.com/Yubico/libu2f-host/master/70-u2f.rules

## ZSH
sudo apt install zsh -y
git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
mkdir -p $HOME/.aliases
cp .aliases/* $HOME/.aliases
touch $HOME/.zshrc
cat zshrc.template.zsh > $HOME/.zshrc
chsh -s /bin/zsh

## Create ssh key
ssh-keygen -t ed25519 -C "$EMAIL"

## Mount NAS in $HOME/Nas/*
mkdir -p $HOME/Nas
mkdir -p $HOME/Nas/Cloud
mkdir -p $HOME/Nas/Downloads
mkdir -p $HOME/Nas/Media

## Printer
sudo cp /etc/sane.d/airscan.conf /etc/sane.d/airscan.conf-BACKUP
echo "[devices]
  "Canon TS3400 series" = http://10.2.20.142:80/eSCL
  "CANON INC. TS3400 series" = http://10.2.20.142:80/wsd/scanservice.cgi, wsd
" | sudo tee /etc/sane.d/airscan.conf > /dev/null

## At last
## Sanity cleanup
sudo apt update -y ; sudo apt upgrade -y ; sudo apt autoremove -y
