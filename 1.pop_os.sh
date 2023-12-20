#!/bin/bash -e
NVM_VERSION=0.39.5
GO_VERSION=1.21.1

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
                    ranger

## Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

## Alacritty: Make sure undercurl works
curl -sSL https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info | tic -x -

## Yubikey
sudo wget -O /etc/udev/rules.d/70-u2f.rules https://raw.githubusercontent.com/Yubico/libu2f-host/master/70-u2f.rules

## Thorium Browser
wget https://dl.thorium.rocks/debian/dists/stable/thorium.list
sudo mv thorium.list /etc/apt/sources.list.d/
sudo apt update
sudo apt install thorium-browser

## BRAVE   
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update -y
sudo apt install -y brave-browser

## FLoorp
curl -fsSL https://ppa.ablaze.one/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/Floorp.gpg
sudo curl -sS --compressed -o /etc/apt/sources.list.d/Floorp.list 'https://ppa.ablaze.one/Floorp.list'
sudo apt update
sudo apt install floorp

## DOCKER
sudo apt-get update
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

## VSCODE SETTINGS
mkdir -p $HOME/.config/Code/User
cp ./vscode/settings.json $HOME/.config/Code/User/settings.json
cp ./vscode/keybindings.json $HOME/.config/Code/User/keybindings.json

## GoLang
wget -c https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz
tar -C $HOME -xvzf go$GO_VERSION.linux-amd64.tar.gz
rm go$GO_VERSION.linux-amd64.tar.gz

## C#
wget https://dot.net/v1/dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh -c Current
rm dotnet-install.sh

## ZSH
sudo apt install zsh -y
git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
mkdir -p $HOME/.aliases
cp .aliases/* $HOME/.aliases
touch $HOME/.zshrc
cat zshrc.template.zsh > $HOME/.zshrc
mkdir -p $HOME/.fonts
echo "fetch fonts from https://www.nerdfonts.com/font-downloads"
# wget 'https://github.com/abertsch/Menlo-for-Powerline/archive/master.zip' -O $HOME/.fonts/master.zip
# unzip $HOME/.fonts/master.zip -d $HOME/.fonts/
# rm $HOME/.fonts/master.zip
# fc-cache -vf $HOME/.fonts
chsh -s /bin/zsh

## NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh | bash

## Lazydocker
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

## Create ssh key
ssh-keygen -t ed25519 -C "$EMAIL"

## Mount NAS in $HOME/Nas/*
sudo mkdir -p $HOME/Nas
sudo mkdir -p $HOME/Nas/Cloud
sudo mkdir -p $HOME/Nas/Downloads
sudo mkdir -p $HOME/Nas/Media
sudo chown $USER:$USER $HOME/Nas

#cat >> /etc/fstab << EOF
#10.2.3.10:/volume1/Cloud                 /home/USER/Nas/Cloud          nfs          defaults    0       0
#10.2.3.10:/volume1/Downloads             /home/USER/Nas/Downloads      nfs          defaults    0       0
#10.2.3.10:/volume1/Media                 /home/USER/Nas/Media          nfs          defaults    0       0
#EOF

## Printer
sudo cp /etc/sane.d/airscan.conf /etc/sane.d/airscan.conf-BACKUP
sudo cat > /etc/sane.d/airscan.conf << EOF
[devices]
  "Canon TS3400 series" = http://10.2.20.142:80/eSCL
  "CANON INC. TS3400 series" = http://10.2.20.142:80/wsd/scanservice.cgi, wsd
EOF

# Just mount them manually so we dont have to reboot
#sudo mount -t nfs 10.2.3.10:/volume1/Cloud $HOME/Nas/Cloud
#sudo mount -t nfs 10.2.3.10:/volume1/Downloads $HOME/Nas/Downloads
#sudo mount -t nfs 10.2.3.10:/volume1/Media $HOME/Nas/Media

## To get rid of some warnings about not symlinking resolv.conf for wireguard 
# sudo dpkg-reconfigure resolvconf


## At last
## Sanity cleanup
sudo apt update -y ; sudo apt upgrade -y ; sudo apt autoremove -y
