#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-only
#

# Init timer
START=$(date +"%s")

# Indonesian timezone (GMT+7)
TZ=Asia/Jakarta
sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime

OURDIR=/mnt/build

# Format and setup 
echo "***** Prepare Persistant Disk path:$OURDIR *****  "
sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
sudo mkdir -p $OURDIR
sudo mount -o discard,defaults /dev/sdb $OURDIR
sudo chmod a+w $OURDIR
sudo cp /etc/fstab /etc/fstab.backup
echo UUID=`sudo blkid -s UUID -o value /dev/sdb` $OURDIR ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
cat /etc/fstab

# Environment setup
echo "***** Environment setup.. *****"
sudo apt-get update
sudo apt install git ccache nano sshpass neofetch zsh -y
sudo /usr/sbin/update-ccache-symlinks
echo export PATH="/usr/lib/ccache:$PATH" | tee -a ~/.bashrc
echo export USE_CCACHE=1 | tee -a ~/.bashrc
echo export CCACHE_EXEC=$(command -v ccache) | tee -a ~/.bashrc
echo export CCACHE_BASEDIR=$OURDIR/.ccache | tee -a ~/.bashrc
echo export CCACHE_DIR=$OURDIR/.ccache | tee -a ~/.bashrc
echo ccache -M 10G | tee -a ~/.bashrc
source ~/.bashrc && echo $PATH
sleep 1

# Add Antigen plugins
echo "***** ZSH INSTALL ANTIGEN *****"
wget https://raw.githubusercontent.com/zsh-users/antigen/master/bin/antigen.zsh -P $HOME/
wget https://github.com/goodmeow/myscript/raw/master/dotfiles/.zshrc -P $HOME/

echo "***** Setup GIT *****"
# For all those distro hoppers, lets setup your git credentials
GIT_USERNAME="$(git config --get user.name)"
GIT_EMAIL="$(git config --get user.email)"
echo -e "[${CLR_BLD_CYA}+${CLR_RST}] ${CLR_BLD_CYA}Configuring Git...${CLR_RST}"
if [[ -z ${GIT_USERNAME} ]]; then
	echo -e "> ${CLR_BLD_RED}Enter your name: ${CLR_RST}"
	read -r NAME
	git config --global user.name "${NAME}"
fi
if [[ -z ${GIT_EMAIL} ]]; then
	echo -e "> ${CLR_BLD_RED}Enter your email: ${CLR_RST}"
	read -r EMAIL
	git config --global user.email "${EMAIL}"
fi
git config --global credential.helper "cache --timeout=7200"
echo -e "[${CLR_BLD_GRN}+${CLR_RST}] ${CLR_BLD_GRN}Setting-up Github credentials setup successfully${CLR_RST}"

# Generating ssh-key for git ssh creds using git email conf
echo "***** Generating SSH-KEY for git using email conf *****"
if [[ ! -e ~/.ssh/id_rsa ]]; then
    echo -e "\n" | ssh-keygen -t rsa -b 4096 -C "$(git config user.email)" -N "" -q > /dev/null
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_rsa 2>/dev/null
    echo -e "[${CLR_BLD_GRN}+${CLR_RST}] ${CLR_BLD_GRN}Github ssh-key succesefully generated${CLR_RST}"
fi
echo -e "[${CLR_BLD_YLW}!${CLR_RST}] ${CLR_BLD_YLW}Github ssh-key already exists, skipping...${CLR_RST}"

# Add SF to known_hosts
ssh-keyscan frs.sourceforge.net >> ~/.ssh/known_hosts

# Setup Android Enviroment
echo "***** Android build env script *****"
git clone https://github.com/akhilnarang/scripts $HOME/scripts
. $HOME/scripts/setup/android_build_env.sh
sleep 1

# End timer
END=$(date +"%s")
DIFF=$(($END - $START))

# Done.
echo -e "\n[${CLR_BLD_GRN}+${CLR_RST}] ${CLR_BLD_PPL}Finish in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s).${CLR_RST}"

# unset all env var
unset START
unset END
unset DIFF
