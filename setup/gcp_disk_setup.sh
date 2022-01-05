#!/bin/bash

OURDIR=

# Format and setup gcp
echo -e "***** Prepare Persistant GCP Disk path:$OURDIR *****"
sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
sudo mkdir -p "$OURDIR"
sudo mount -o discard,defaults /dev/sdb "$OURDIR"
sudo chmod a+w "$OURDIR"
sudo cp /etc/fstab /etc/fstab.backup
echo UUID=$(sudo blkid -s UUID -o value /dev/sdb) "$OURDIR" ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
cat /etc/fstab
echo -e  "***** Done Persistant GCP Disk path:$OURDIR *****"