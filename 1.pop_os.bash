#!/bin/bash -e

[ -z "${HOME}" ] && echo "\$HOME not specified" && exit 1
[ -z "${EMAIL}" ] && echo "\$EMAIL not specified" && exit 1

flatpak update

# Set to use local time and not utc
timedatectl set-local-rtc 1 --adjust-system-clock

sudo apt-add-repository ppa:git-core/ppa -y
sudo apt update -y ; sudo apt upgrade -y

mkdir -p $HOME/git
mkdir -p $HOME/.bin

## APPS
sudo apt install -y curl \
                    git \
                    wget \
                    net-tools \
                    htop \
                    lm-sensors \
                    ffmpeg \
                    mpv \
                    nfs-common \
                    screen \
                    steam \
                    sane-airscan \
                    wireguard \
                    w3m  \
                    w3m-img  \
                    doublecmd-gtk \
                    meld \
                    ranger \
                    xclip \
                    flameshot \
                    i3 i3blocks i3lock xautolock peek feh thunar blueman pavucontrol arandr rofi lxpolkit

## Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

## Alacritty: Make sure undercurl works
curl -sSL https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info | tic -x -

## Yubikey
sudo wget -O /etc/udev/rules.d/70-u2f.rules https://raw.githubusercontent.com/Yubico/libu2f-host/master/70-u2f.rules

## BRAVE
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null
sudo apt update -y
sudo apt install -y brave-browser

## FLoorp
curl -fsSL https://ppa.ablaze.one/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/Floorp.gpg
sudo curl -sS --compressed -o /etc/apt/sources.list.d/Floorp.list 'https://ppa.ablaze.one/Floorp.list'
sudo apt update -y
sudo apt install -y floorp

## DOCKER
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

VERSION_CODENAME=$(lsb_release -cs)
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \

sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo groupadd docker
sudo usermod -aG docker $USER
## END DOCKER

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
