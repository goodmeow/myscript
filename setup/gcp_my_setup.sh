#!/bin/bash

# Init timer
START=$(date +"%s")

# Indonesian timezone (GMT+7)
TZ=Asia/Jakarta
sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime

OURDIR=/mnt/build
GIT_USERNAME="$(git config --get user.name)"
GIT_EMAIL="$(git config --get user.email)"

# Format and setup
echo -e "Prepare Persistant Disk path:$OURDIR .."
sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
sudo mkdir -p $OURDIR
sudo mount -o discard,defaults /dev/sdb $OURDIR
sudo chmod a+w $OURDIR
sudo cp /etc/fstab /etc/fstab.backup
echo UUID=$(sudo blkid -s UUID -o value /dev/sdb) $OURDIR ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
cat /etc/fstab

# Environment setup
echo -e "Environment setup.."
sudo apt-get update
sudo apt install git ccache nano sshpass neofetch zsh -y
sudo /usr/sbin/update-ccache-symlinks
echo export PATH="/usr/lib/ccache:$PATH" | tee -a ~/.bashrc
echo export USE_CCACHE=1 | tee -a ~/.bashrc
echo export CCACHE_EXEC=$(command -v ccache) | tee -a ~/.bashrc
echo export CCACHE_BASEDIR=$OURDIR/.ccache | tee -a ~/.bashrc
echo export CCACHE_DIR=$OURDIR/.ccache | tee -a ~/.bashrc
echo ccache -M 10G | tee -a ~/.bashrc
source $HOME/.bashrc && echo "$PATH"
sleep 1


echo -e "git Setup.."
# For all those distro hoppers, lets setup your git credentials
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
echo -e "Generating SSH-KEY for git using provided email.."
if [[ ! -e ~/.ssh/id_rsa ]]; then
    echo -e "\n" | ssh-keygen -t rsa -b 4096 -C "$(git config user.email)" -N "" -q > /dev/null
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_rsa 2>/dev/null
    echo -e "[${CLR_BLD_GRN}+${CLR_RST}] ${CLR_BLD_GRN}Github ssh-key succesefully generated${CLR_RST}"
    # Add SF to known_hosts
    ssh-keyscan frs.sourceforge.net >> ~/.ssh/known_hosts 2>/dev/null
    else
    echo -e "[${CLR_BLD_YLW}!${CLR_RST}] ${CLR_BLD_YLW}Github ssh-key already exists, skipping...${CLR_RST}"
fi

# Setup Android Enviroment
echo -e "Android build env script *****"
git clone https://github.com/akhilnarang/scripts $HOME/scripts
. $HOME/scripts/setup/android_build_env.sh
sleep 1

# Install Open JDK, Jenkins and Apache
echo -e "Install Open JDK, Jenkins and Apache.."
wget -qO - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

sudo apt-get update
sudo apt install openjdk-8-jdk jenkins apache2 -y
sleep 1

# then start both apache and jenkins
echo -e "Starting jenkins & apache service.."
sudo systemctl start apache2
sudo systemctl start jenkins

# add Jenkins web apache2 config
echo -e "adding and symlinking jenkins apache config.."
sudo wget https://github.com/goodmeow/myscript/raw/master/ci/jenkins/jenkins.conf -P /etc/apache2/sites-available/
sudo chmod 644 /etc/apache2/sites-available/jenkins.conf

# a2enmod
echo -e "a2enmod proxy & proxy http.."
sudo a2enmod proxy
sudo a2enmod proxy_http
echo -e "a2ensite jenkins & apache.."
sudo a2ensite jenkins
sudo systemctl restart apache2
sudo systemctl restart jenkins

# Add Antigen plugins
echo -e "Add zsh Antigen plugins.."
wget https://raw.githubusercontent.com/zsh-users/antigen/master/bin/antigen.zsh -P $HOME/
wget https://github.com/goodmeow/myscript/raw/master/dotfiles/.zshrc -P $HOME/

# End timer
END=$(date +"%s")
DIFF=$(($END - $START))

# Done.
echo -e "\n[${CLR_BLD_GRN}+${CLR_RST}] ${CLR_BLD_PPL}Finish in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s).${CLR_RST}"

# unset all env var
unset START
unset END
unset DIFF