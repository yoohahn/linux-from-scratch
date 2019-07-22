#!/bin/bash
[ -z "${UBUNTU_CODENAME}" ] && echo "UBUNTU_CODENAME not specified" && exit 1
[ -z "${HOME}" ] && echo "HOME not specified" && exit 1
# https://github.com/guard/listen/wiki/Increasing-the-amount-of-inotify-watchers
# echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

sudo apt-get update -y ; sudo apt-get upgrade -y
if [ $UBUNTU_CODENAME -eq "bionic" ]; then
  sudo apt-get install -y git
  NUMIX_ICON=numix-icon-theme
else
  sudo snap install --classic git
  NUMIX_ICON=numix-icon-theme-circle
fi

mkdir -p $HOME/git
[ -z "${NUMIX_ICON}" ] && echo "NUMIX_ICON not specified" && exit 1

## APPS AND THEMES
sudo apt-get install -y curl wget terminator net-tools kdiff3 htop
sudo apt-get install -y arc-theme gnome-tweak-tool numix-gtk-theme $NUMIX_ICON chrome-gnome-shell

## Yubikey
sudo wget -O /etc/udev/rules.d/70-u2f.rules https://raw.githubusercontent.com/Yubico/libu2f-host/master/70-u2f.rules

## ZSH
sudo apt install zsh -y
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
sudo apt install fonts-powerline -y
cp $HOME/.zshrc $HOME/.zshrc-orig
sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"agnoster\"/g' $HOME/.zshrc
git clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
sed -i 's/plugins\=(/plugins\=(zsh-autosuggestions zsh-syntax-highlighting /g' $HOME/.zshrc
mkdir -p $HOME/.fonts
wget https://github.com/abertsch/Menlo-for-Powerline/archive/master.zip -O $HOME/.fonts/master.zip
unzip $HOME/.fonts/master.zip
rm $HOME/.fonts/master.zip
fc-cache -vf $HOME/.fonts
#### Copy alias to ZSH
cat zshrc-alias >> $HOME/.zshrc

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

## VSCODE SETTINGS
mkdir -p $HOME/.config/Code/User
cp ./vscode/settings.json $HOME/.config/Code/User/settings.json

## DOCK
### BOTTOM
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
### TRANSPARENCY
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
## NO STRETCH
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
### SIZE
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 28
### TITLEBAR ICONS LEFT
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
### SHOW WEEKS IN CALENDAR
gsettings set org.gnome.desktop.calendar show-weekdate true

## Sanity cleanup
sudo apt-get update -y ; sudo apt-get upgrade -y ; sudo apt-get autoremove -y
