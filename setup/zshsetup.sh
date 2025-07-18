#!/usr/bin/env bash

set -euo pipefail

echo "***** ZSH INSTALL & ANTIGEN SETUP *****"

# Install zsh jika belum ada
if ! command -v zsh &> /dev/null; then
    echo "Installing ZSH..."
    sudo apt-get update
    sudo apt-get install -y zsh
else
    echo "ZSH already installed."
fi

# Install fonts for powerline
echo "Installing Powerline fonts..."
sudo apt-get install -y powerline fonts-powerline

# Download antigen if not exists
ANTIGEN_PATH="$HOME/antigen.zsh"
if [[ ! -f "$ANTIGEN_PATH" ]]; then
    echo "Downloading Antigen..."
    wget -q https://raw.githubusercontent.com/zsh-users/antigen/master/bin/antigen.zsh -O "$ANTIGEN_PATH"
else
    echo "Antigen already downloaded."
fi

# Download .zshrc if not exists
ZSHRC_PATH="$HOME/.zshrc"
if [[ ! -f "$ZSHRC_PATH" ]]; then
    echo "Downloading .zshrc template..."
    wget -q https://github.com/goodmeow/myscript/raw/master/dotfiles/.zshrc -O "$ZSHRC_PATH"
else
    echo ".zshrc already exists. Skipping download."
fi

# Ubah shell default ke zsh jika belum
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    echo "Changing default shell to ZSH..."
    chsh -s "$(command -v zsh)"
    echo "Shell changed. Please log out and log back in to use ZSH by default."
fi

# Jalankan zsh jika tidak sedang di dalamnya
if [[ "$SHELL" != *zsh ]]; then
    echo "Launching ZSH..."
    exec zsh
else
    echo "Already in ZSH shell."
    source "$ZSHRC_PATH"
fi
