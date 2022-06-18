#! /usr/bin/bash

wget https://raw.githubusercontent.com/usmanmughalji/gdriveupload/master/gdrive
chmod +x gdrive
sudo install gdrive /usr/local/bin/gdrive
rm -rf gdrive
gdrive list

