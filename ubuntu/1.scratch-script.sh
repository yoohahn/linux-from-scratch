#!/bin/bash
[ -z "${UBUNTU_CODENAME}" ] && echo "UBUNTU_CODENAME not specified" && exit 1
# https://github.com/guard/listen/wiki/Increasing-the-amount-of-inotify-watchers
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

sudo apt-get update -y ; sudo apt-get upgrade -y
sudo snap install --classic git
mkdir -p ~/git
## CURL
sudo apt-get install -y curl wget terminator net-tools kdiff3

## ZSH
sudo apt install zsh -y
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
sudo apt install fonts-powerline -y
cp ~/.zshrc ~/.zshrc-orig
sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"agnoster\"/g' ~/.zshrc
mkdir -p ~/.fonts
cd ~/.fonts
wget https://github.com/abertsch/Menlo-for-Powerline/archive/master.zip
unzip master.zip
rm master.zip
fc-cache -vf ~/.fonts
cd ~

nano ~/.oh-my-zsh/themes/agnoster.zsh-theme
cd ~/.oh-my-zsh/custom/plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions
sed -i 's/plugins\=(/plugins\=(zsh-autosuggestions zsh-syntax-highlighting /g' ~/.zshrc

## BRAVE
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
source /etc/os-release

echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/brave-browser-release-${UBUNTU_CODENAME}.list

sudo apt-get update -y

sudo apt-get install brave-keyring brave-browser -y

## DOCKER
sudo apt-get install apt-transport-https ca-certificates software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get install docker docker.io docker-compose -y
sudo groupadd docker
sudo usermod -aG docker $USER

## VSCODE
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get install apt-transport-https -y
sudo apt-get update -y
sudo apt-get install code -y

## Graphics
sudo apt-get purge nvidia* -y
sudo add-apt-repository ppa:graphics-drivers -y
sudo add-apt-repository ppa:graphics-drivers/ppa -y
sudo apt-get update -y
sudo apt install nvidia-driver-418 -y

## VLC
sudo snap install vlc

## NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash

## Sanity cleanup
sudo apt-get update -y ; sudo apt-get upgrade -y ; sudo apt-get autoremove -y
