#!/bin/bash -e
mkdir -p ~/.local/share/fonts

cd /tmp
fonts=(
"JetBrainsMono"
 "RobotoMono"
 "UbuntuMono"
)

for font in ${fonts[@]}
do
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/$font.zip
    unzip $font.zip -d $HOME/.local/share/fonts/$font/
    rm $font.zip
done

fc-cache
