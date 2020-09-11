#!/usr/bin/env bash

echo "install zsh & ohmyzsh - ubuntu"

sudo apt-get update
sudo apt-get install zsh -y
sudo usermod -s /usr/bin/zsh "$(whoami)"

#powerline/fonts
sudo apt-get install powerline fonts-powerline -y
#oh-myzsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git .oh-my-zsh/themes/powerlevel10k
#echo Set ZSH_THEME="powerlevel10k/powerlevel10k" >> ~/.zshrc
#source $HOME/.zshrc

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

