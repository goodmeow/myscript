#!/bin/bash

# User Defined Stuff
user="harun"

# Build env definition
# TODO: bootimage, apk compilation only
lunch_command="nad"
device_codename="apollo"
build_type="userdebug"

gapps_command="USE_GAPPS"
with_gapps="yes"
use_brunch="yes"

# ROM Path definition
folder="/home/${user}/nad"
rom_name="Nusantara"*.zip
OUT_PATH="$folder/out/target/product/${device_codename}"
ROM=${OUT_PATH}/${rom_name}

# make_clean set to (yes|no|installclean)
make_clean="installclean"
#make_clean="no"
#make_clean="yes"

# Telegram Config
priv_to_me="/home/dump/configs/priv.conf"
newpeeps="/home/dump/configs/"${user}.conf

tg_send () {
    sudo telegram-send --format html "$1" --config ${priv_to_me} --disable-web-page-preview
    sudo telegram-send --format html "$1" --config ${newpeeps} --disable-web-page-preview
}

# Go to build directory
cd "$folder"
echo -e "\rBuild starting thank you for waiting"
BLINK="https://ci.goindi.org/job/$JOB_NAME/$BUILD_ID/console"

read -r -d '' $1 <<EOT
<b>Build Started</b>
${lunch} for  ${device_codename}
<b>Console log:-</b> <a href="${BLINK}">here</a>
Good Luck ! Hope it Boots ! Happy Building !
Visit goindi.org  for more
EOT
tg_send $1

# Time to build
if [ -d ${ccache_location} ] then
        echo "Ccache folder  exists."
        else
        sudo chmod -R 777 ${ccache_location}
        echo "Made Ccache Folder "
fi

export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
export CCACHE_DIR=${folder}/.ccache
ccache -M 75G

source build/envsetup.sh

# Gapps export to env
if [ "$with_gapps" = "yes" ]; then
    export "$gapps_command"=true
    else
    export "$gapps_command"=false
fi

# Clean build
if [ "$make_clean" = "yes" ]; then
    make clobber
    echo -e "Clean Build";
fi
if [ "$make_clean" = "installclean" ]; then
    make installclean
    echo -e "Install Clean";
fi
if [ "$use_brunch" = "yes" ]; then
    brunch ${device_codename}
    else
    lunch ${lunch_command}_${device_codename}-${build_type}
    make  ${lunch_command} -j$(nproc --all)
fi
if [ "$use_brunch" = "bacon" ]; then
    lunch ${lunch_command}_${device_codename}-${build_type}
    make bacon -j$(nproc --all)
fi

# ROM
if [ -f $ROM ]; then
    mkdir -p /home/dump/sites/goindi/downloads/${user}/${device_codename}
    cp $ROM /home/dump/sites/goindi/downloads/${user}/${device_codename}

    # Finished build notification
    filename="$(basename $ROM)"
    LINK="https://download.goindi.org/${user}/${device_codename}/${filename}"
    size="$(du -h ${ROM}|awk '{print $1}')"
    mdsum="$(md5sum ${zip}|awk '{print $1}')"
    read -r -d '' priv <<EOT
    Yay it's finished !
    ${lunch} for  ${device_codename}
    <b>Download:-</b> <a href="${LINK}">here</a>
    <b>Size:-</b> <pre> ${size}</pre>
    <b>Md5:-</b> <pre> ${mdsum}</pre>
EOT
tg_send $1
    else
    # Error notification
    read -r -d '' $1 <<EOT
    <b>Error Generated</b>
    <b>Check error:-</b> <a href="https://ci.goindi.org/job/$JOB_NAME/$BUILD_ID/console">here</a>
EOT
tg_send $1
fi