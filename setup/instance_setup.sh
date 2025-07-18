#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-only
#

set -euo pipefail

# Timer mulai
START=$(date +%s)

# Handle error
trap 'echo "Terjadi kesalahan pada baris $LINENO"; exit 1' ERR

# Timezone Indonesia
TZ="Asia/Jakarta"
sudo ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime

echo "***** Setting up Environment *****"
sudo apt-get update
sudo apt-get install -y git ccache nano sshpass neofetch shellcheck

# Jalankan ShellCheck pada script ini
shellcheck "$0"

echo "***** Setting up Git *****"
GIT_USERNAME="$(git config --get user.name || true)"
GIT_EMAIL="$(git config --get user.email || true)"

# Setup Git user.name
if [[ -z "${GIT_USERNAME}" ]]; then
    read -rp "Enter your name: " NAME
    if [[ ! "$NAME" =~ ^[a-zA-Z0-9\.\'\ -]+$ ]]; then
        echo "Invalid name format. Use letters, numbers, dots, or spaces."
        exit 1
    fi
    git config --global user.name "${NAME}"
fi

# Setup Git user.email
if [[ -z "${GIT_EMAIL}" ]]; then
    read -rp "Enter your email: " EMAIL
    if [[ ! "$EMAIL" =~ ^[[:alnum:]\._%+-]+@[[:alnum:]\.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo "Invalid email format."
        exit 1
    fi
    git config --global user.email "${EMAIL}"
fi

git config --global credential.helper "cache --timeout=7200"
echo "Git credentials setup successfully."

echo "***** Generating SSH-KEY for Git *****"
SSH_KEY="$HOME/.ssh/id_rsa"
if [[ ! -f "$SSH_KEY" ]]; then
    mkdir -p ~/.ssh
    ssh-keygen -t rsa -b 4096 -C "$(git config user.email)" -N "" -q -f "$SSH_KEY"
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add "$SSH_KEY" 2>/dev/null
    echo "GitHub SSH key generated."
else
    echo "SSH key already exists. Skipping generation."
fi

# Tambahkan SourceForge ke known_hosts
mkdir -p ~/.ssh
ssh-keyscan frs.sourceforge.net >> ~/.ssh/known_hosts 2>/dev/null

echo "***** Setting up Android Build Environment *****"
if [[ ! -d "$HOME/scripts" ]]; then
    git clone https://github.com/akhilnarang/scripts "$HOME/scripts"
fi

echo "Adding GitHub CLI key and repository..."
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
https://cli.github.com/packages stable main" | \
    sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Jalankan script environment
. "$HOME/scripts/setup/android_build_env.sh"

# Setup ccache
sudo mkdir -p /mnt/ccache

# Tambahkan ke .bashrc jika belum ada
grep -qxF 'export PATH="/usr/lib/ccache:$PATH"' ~/.bashrc || echo 'export PATH="/usr/lib/ccache:$PATH"' >> ~/.bashrc
grep -qxF 'export USE_CCACHE=1' ~/.bashrc || echo 'export USE_CCACHE=1' >> ~/.bashrc
grep -qxF "export CCACHE_EXEC=$(command -v ccache)" ~/.bashrc || echo "export CCACHE_EXEC=$(command -v ccache)" >> ~/.bashrc

# Selesai, tampilkan waktu eksekusi
END=$(date +%s)
DIFF=$((END - START))
echo "Finished in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)."

# Cleanup variabel
unset START END DIFF GIT_USERNAME GIT_EMAIL NAME EMAIL SSH_KEY TZ
