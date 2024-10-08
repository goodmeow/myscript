#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-only
#

# Init timer
START=$(date +"%s")

# Indonesian timezone (GMT+7)
TZ=Asia/Jakarta
sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime

echo "***** Setting up Environment *****"
sudo apt-get update
sudo apt install git ccache nano sshpass neofetch -y shellcheck

# Run ShellCheck to analyze the script
shellcheck "$0"

echo "***** Setting up Git *****"
# For all those distro hoppers, let's set up your Git credentials
GIT_USERNAME="$(git config --get user.name)"
GIT_EMAIL="$(git config --get user.email)"

if [[ -z "${GIT_USERNAME}" ]]; then
    read -p "Enter your name: " NAME
    # Validate name input using regular expression
    if [[ ! "$NAME" =~ ^[[:alnum:]]+$ ]]; then
        echo "Invalid name format. Please enter only alphanumeric characters."
        exit 1
    fi
    git config --global user.name "${NAME}"
fi

if [[ -z ${GIT_EMAIL}" ]]; then
    read -p "Enter your email: " EMAIL
    # Validate email input using regular expression
    if [[ ! "$EMAIL" =~ ^[[:alnum:]\._-]+\@[[:alnum:]\._-]+\.[[:alnum:]]+$ ]]; then
        echo "Invalid email format."
        exit 1
    fi
    git config --global user.email "${EMAIL}"
fi

git config --global credential.helper "cache --timeout=7200"
echo "Git credentials setup successfully"

echo "***** Generating SSH-KEY for git using email conf *****"
# Generating ssh-key for git ssh creds using git email conf
if [[ ! -e ~/.ssh/id_rsa ]]; then
    # Use a secure temporary directory for the SSH key
    tmp_dir=$(mktemp -d "/tmp/ssh-key-XXXXXX")
    ssh-keygen -t rsa -b 4096 -C "$(git config user.email)" -N "" -q -f "$tmp_dir/id_rsa"
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add "$tmp_dir/id_rsa" 2>/dev/null
    mv "$tmp_dir/id_rsa" ~/.ssh/id_rsa
    rm -rf "$tmp_dir"
    echo "Github ssh-key successfully generated"
else
    echo "Github ssh-key already exists, skipping..."
fi

# Add SF to known_hosts
ssh-keyscan frs.sourceforge.net >> ~/.ssh/known_hosts

echo "***** Setting up Android Build Environment *****"
git clone https://github.com/akhilnarang/scripts $HOME/scripts
echo "Adding GitHub apt key and repository!"
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
. $HOME/scripts/setup/android_build_env.sh
sudo mkdir /mnt/ccache
echo export PATH="/usr/lib/ccache:$PATH" >> ~/.bashrc
echo export USE_CCACHE=1 >> ~/.bashrc
echo export CCACHE_EXEC=$(command -v ccache) >> ~/.bashrc

# End timer
END=$(date +"%s")
DIFF=$(($END - $START))

echo "Finished in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)."

# unset all env var
unset START
unset END
unset DIFF
