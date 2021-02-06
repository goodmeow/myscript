# Format and setup
echo "***** Prepare Persistant SSDisk path:/mnt/build *****  "
sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/nvme0n1
sudo mkdir -p /mnt/build
sudo mount -o discard,defaults /dev/nvme0n1 /mnt/build
sudo chmod a+w /mnt/build
#sudo cp /etc/fstab /etc/fstab.backup
#echo UUID=`sudo blkid -s UUID -o value /nvme0n1` /mnt/build ext4 discard,defaults,nofail 0 2$
#cat /etc/fstab
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer
exit 0
