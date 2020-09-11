#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-only
#

# Init timer
START=$(date +"%s")

# Indonesian timezone (GMT+7)
TZ=Asia/Jakarta
sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime

echo "***** Enviroment setup.. *****"
sudo apt-get update
sudo apt install git ccache nano sshpass neofetch zsh -y
sudo /usr/sbin/update-ccache-symlinks
echo export PATH="/usr/lib/ccache:$PATH" | tee -a ~/.bashrc
echo export USE_CCACHE=1 | tee -a ~/.bashrc
echo export CCACHE_EXEC=$(command -v ccache) | tee -a ~/.bashrc
echo ccache -M 50G | tee -a ~/.bashrc
source ~/.bashrc && echo $PATH
sleep 1

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

echo "***** Generating SSH-KEY for git using email conf *****"
# Generating ssh-key for git ssh creds using git email conf
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

# Install Open JDK, Jenkins and Apache
echo "Install Open JDK, Jenkins and Apache"
wget -qO - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

sudo apt-get update
sudo apt install openjdk-8-jdk jenkins apache2 -y
sleep 1

# then start botj apache and jenkins
sudo systemctl start apache2
sudo systemctl start jenkins

# add Jenkins web apache2 config
echo "adding and symlinking config /etc/apache2/sites-available/jenkins"
sudo wget https://github.com/goodmeow/myscript/raw/master/ci/jenkins/jenkins.conf -P /etc/apache2/sites-available/
sudo chmod 644 /etc/apache2/sites-available/jenkins.conf

# a2enmod
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2ensite jenkins
sudo systemctl restart apache2
sudo systemctl restart jenkins

# End timer
END=$(date +"%s")
DIFF=$(($END - $START))

# Done.
echo -e "\n[${CLR_BLD_GRN}+${CLR_RST}] ${CLR_BLD_PPL}Finish in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s).${CLR_RST}"

# unset all env var
unset START
unset END
unset DIFF

#####################################
echo "***** ZSH INSTALL ANTIGEN *****"
wget https://raw.githubusercontent.com/zsh-users/antigen/master/bin/antigen.zsh -P $HOME/
wget https://github.com/goodmeow/myscript/raw/master/dotfiles/.zshrc -P $HOME/
#sudo chsh -s /bin/zsh
zsh
source .zshrc
