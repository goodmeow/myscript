#! /usr/bin/bash
sudo mkfs -t ext4 /dev/sdc
mkdir $HOME/build
sudo chmod a+w $HOME/build
sudo mount -o discard,defaults /dev/sdc $HOME/build
sudo cp /etc/fstab /etc/fstab.backup
echo UUID=`sudo blkid -s UUID -o value /dev/sdc` $HOME/build ext4 discard,defaults,nofail 1 2 | sudo tee -a /etc/fstab
