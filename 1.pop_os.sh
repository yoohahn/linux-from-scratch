#!/bin/bash -e
NVM_VERSION=0.38.0
GO_VERSION=1.17

[ -z "${HOME}" ] && echo "\$HOME not specified" && exit 1
[ -z "${EMAIL}" ] && echo "\$EMAIL not specified" && exit 1

# Set to use local time and not utc
timedatectl set-local-rtc 1 --adjust-system-clock

sudo apt-add-repository ppa:git-core/ppa -y
sudo apt-get update -y ; sudo apt-get upgrade -y

mkdir -p $HOME/git
mkdir -p $HOME/.bin

## APPS
sudo apt-get install -y curl git wget terminator net-tools htop gnome-tweak-tool lm-sensors

## Yubikey
sudo wget -O /etc/udev/rules.d/70-u2f.rules https://raw.githubusercontent.com/Yubico/libu2f-host/master/70-u2f.rules

## BRAVE   
sudo apt install apt-transport-https -y
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update -y
sudo apt install brave-browser -y

## DOCKER
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo apt-key add - \
  && sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y && sudo apt-get install docker-ce docker-ce-cli containerd.io -y

sudo groupadd docker
sudo usermod -aG docker $USER
## END DOCKER

## VSCODE SETTINGS
mkdir -p $HOME/.config/Code/User
cp ./vscode/settings.json $HOME/.config/Code/User/settings.json

## GoLang
wget -c https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz
tar -C $HOME/.bin -xvzf go$GO_VERSION.linux-amd64.tar.gz
rm go$GO_VERSION.linux-amd64.tar.gz

## C#
wget https://dot.net/v1/dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh -c Current
rm dotnet-install.sh

## ZSH
sudo apt install zsh -y
sudo apt install powerline fonts-powerline -y
git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
mkdir -p $HOME/.aliases
cp .aliases/* $HOME/.aliases
touch $HOME/.zshrc
cat zshrc.template > $HOME/.zshrc
mkdir -p $HOME/.fonts
wget 'https://github.com/abertsch/Menlo-for-Powerline/archive/master.zip' -O $HOME/.fonts/master.zip
unzip $HOME/.fonts/master.zip -d $HOME/.fonts/
rm $HOME/.fonts/master.zip
fc-cache -vf $HOME/.fonts
chsh -s /bin/zsh

## NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh | bash

## Sanity cleanup
sudo apt-get update -y ; sudo apt-get upgrade -y ; sudo apt-get autoremove -y

## Create ssh key
ssh-keygen -t ed25519 -C "$EMAIL"
