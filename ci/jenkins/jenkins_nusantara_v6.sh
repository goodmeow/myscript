#!/bin/bash

#####################################################
# Copyright (C) 2020 @alanndz (Telegram and Github) #
#                    @goodmeow (github)             #
# SPDX-License-Identifier: GPL-3.0-or-later         #
#####################################################

# use_ccache=
# YES - use ccache
# NO - don't use ccache
# CLEAN - clean your ccache (Do this if you getting Toolchain errors related to ccache and it will take some time to clean all ccache files)

# make_clean=
# YES - make clean (this will delete "out" dir from your ROM repo)
# NO - make dirty
# INSTALLCLEAN - make installclean (this will delete all images generated in out dir. useful for rengeneration of images)

# lunch_command
# LineageOS uses "lunch lineage_devicename-userdebug"
# AOSP uses "lunch aosp_devicename-userdebug"
# So enter what your uses in Default Value
# Example - du, xosp, pa, etc

# device_codename
# Enter the device codename that you want to build without qoutes
# Example - "hydrogen" for Mi Max
# "armani" for Redmi 1S

# build_type
# userdebug - Like user but with root access and debug capability; preferred for debugging
# user - Limited access; suited for production
# eng - Development configuration with additional debugging tools

# target_command
# bacon - for compiling rom
# bootimage - for compiling only kernel in ROM Repo
# Settings, SystemUI for compiling particular APK

#################################
#        Variable setup         #
#################################

# use_ccache is not set (yes|no|installclean)
# make_clean is not set (yes|no|installclean)
# lunch_command is not set (nad)
# device_codename is not set
# build_type is not set
# target_command is not set (bacon)
# jobs is not set (nproc)
# upload_to_sf is not set (yes/test)
path_ccache=$PWD/.ccache
javamemory=-Xmx8g 
size_ccache=150G

CDIR=$PWD
OUT="${CDIR}/out/target/product/$device_codename"
ROM_NAME="Nusantara"
DEVICE="$device_codename"
MANIFEST="ssh://git@github.com/Nusantara-ROM/android"
# BRANCH_MANIFEST is not set
OTA="${OUT}/$ROM_NAME*.json"
# NAD_FILE is not set
SF_USER="goodmeow"
SF_PROJECT="nusantaraproject"
SF_PROJECT_TEST="goodmeow"
SF_PASS=""

# Telegram Function
BOT_API_KEY=""
CHAT_ID="-"

#####################################
#           Variable Check          #
#####################################
if [ "$BOT_API_KEY" = "" ]; then
  echo -e "Bot Api not set, please setup first"
  exit 20
fi
if [ "$CHAT_ID" = "" ]; then
  echo -e "Env CHAT_ID not set, please setup first"
  exit 20
fi
if [ "$SF_USER" = "" ]; then
  echo -e "$SF_USER not set, please setup first"
  exit 40
fi
if [ "$SF_PROJECT" = "" ]; then
  echo -e "$SF_PROJECT not set, please setup first"
  exit 40
fi
if [ "$SF_PROJECT_TEST" = "" ]; then
  echo -e "$SF_PROJECT_TEST not set, please setup first"
  exit 40
fi
if [ "$SF_PASS" = "" ]; then
  echo -e "$SF_PASS not set, please setup first"
  exit 40
fi

if ! [ -x "$(command -v gdrive)" ]; then
  echo -e "Error: gdrive is not installed." >&2
  exit 40
fi

# Defining build variant
if [ "$ROMBUILD" = "gapps" ]; then
    export USE_GAPPS=true
fi

if [ "$ROMBUILD" = "microg" ]; then
    export USE_MICROG=true
fi

if [ "$ROMBUILD" = "gms" ]; then
    export USE_GMS=true
fi

#####################################
#               Main                #
#####################################

export TZ=":Asia/Jakarta"
export TERM=xterm

    red=$(tput setaf 1)             #  red
    grn=$(tput setaf 2)             #  green
    blu=$(tput setaf 4)             #  blue
    cya=$(tput setaf 6)             #  cyan
    txtrst=$(tput sgr0)             #  Reset

if [ ! -f ~/.ssh/config ]; then
         echo "creating ssh config for port 22:2"
	 echo "Host *" >> ~/.ssh/config
	 echo "		IdentitiesOnly=yes" >> ~/.ssh/config
	 echo "ssh config for port 22:2, done"
fi

if [ "$re_sync" = "yes" ]; then
    rm -rf .repo/local_manifest* hardware/qcom*
    repo init -u $MANIFEST  -b $BRANCH_MANIFEST
    repo sync -c -j$(nproc) --force-sync --no-clone-bundle --no-tags
    #git clone git@github.com:Nusantara-ROM/android_external_motorola_faceunlock.git external/motorola/faceunlock
fi

if [ "$use_ccache" = "yes" ]; then
	echo -e ${blu}"CCACHE is enabled for this build"${txtrst}
	export CCACHE_EXEC=$(which ccache)
	export USE_CCACHE=1
	export CCACHE_DIR=$path_ccache
	ccache -M $size_ccache
fi

if [ "$use_ccache" = "clean" ]; then
	export CCACHE_EXEC=$(which ccache)
	export CCACHE_DIR=$path_ccache
	ccache -C
	export USE_CCACHE=1
	ccache -M $size_ccache
	wait
	echo -e ${grn}"CCACHE Cleared"${txtrst};
fi

function sendInfo() {
	curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d chat_id=$CHAT_ID -d "parse_mode=HTML" -d text="$(
		for POST in "${@}"; do
			echo "${POST}"
		done
	)" &> /dev/null
}

function sendLog() {
	curl -F chat_id=$CHAT_ID -F document=@"$1" https://api.telegram.org/bot$BOT_API_KEY/sendDocument &>/dev/null
}

function sendTele() {
	curl -F chat_id=$CHAT_ID -F document=@"$1" https://api.telegram.org/bot$BOT_API_KEY/sendDocument &>/dev/null
}

function timeStart() {
	DATELOG=$(date "+%H%M-%d%m%Y")
	BUILD_START=$(date +"%s")
	DATE=`date`
}

function timeEnd() {
	BUILD_END=$(date +"%s")
	DIFF=$(($BUILD_END - $BUILD_START))
}

function startTele() {
	    sendInfo \
	        "<b>====== Starting Build ROM ======</b>" \
		"<b>ROM Name      :</b> <code>${ROM_NAME}</code>" \
		"<b>Branch        :</b> <code>${BRANCH_MANIFEST}</code>" \
		"<b>Device        :</b> <code>${DEVICE}</code>" \
		"<b>Command       :</b> <code>${target_command}</code>" \
		"<b>Upload to SF  :</b> <code>${upload_to_sf}</code>" \
		"<b>Started at    :</b> <code> $(uname -a)</code>" \
		"<b>Instance Uptime :</b> <code> $(uptime -p)</code>" \
		"<b>====== Starting Build ROM ======</b>"
}

function statusBuild() {
    if [[ $retVal -ne 0 ]]; then
            sendInfo "<b>====== Build ROM Failed ======</b>" \
             "Build failed Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
             echo " ***** Build Failed *****  "
        sendLog "$BUILDLOG"
        LOGTRIM="$CDIR/out/log_trimmed.log"
        sed -n '/FAILED:/,//p' $BUILDLOG &> $LOGTRIM
        sendLog "$LOGTRIM"
        exit $retVal
    fi
    if [[ $retVal -eq 141 ]]; then
            sendInfo "<b>====== Build ROM Aborted ======</b>" \
            "Build failed Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
            echo " ***** Build Aborted *****  "
            exit $retVal
    fi
    if [[ $retVal -eq 20 ]]; then
            sendInfo "<b>====== Build ROM Aborted ======</b>" \
            "Build failed Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
            echo "Telegram vars aren't configure yet.. "
            echo " ***** Build Aborted *****  "
            exit $retVal
    fi
    if [[ $retVal -eq 40 ]]; then
            sendInfo "<b>====== Build ROM Aborted ======</b>" \
            "Build failed Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds." \
            "Sourceforge is not configured, please check again.."
            echo " ***** Build Aborted *****  "
            exit $retVal
    fi
    FILENAME=$(cat $CDIR/out/var-file_name)
    PATHJSON=$(find $OUT -name "$ROM_NAME*.json")
    sendTele "$PATHJSON"
    sendInfo \
    "Build Success. Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds." \
    "Filename: $FILENAME " \
    "<b>====== Build ROM Completed ======</b>"
}

timeStart
BUILDLOG="$CDIR/out/${ROM_NAME}-${DEVICE}-${DATELOG}.log"
# time to build bro
export KBUILD_BUILD_USER=jenkins-$ROM_NAME-project
export KBUILD_BUILD_HOST=ci
export JAVA_TOOL_OPTIONS=$javamemory #-Xmx2g
source build/envsetup.sh

if [ "$make_clean" = "yes" ]; then
	make clobber
	wait
	echo -e ${cya}"OUT dir from your repo deleted"${txtrst};
fi

if [ "$make_clean" = "installclean" ]; then
	make installclean && make clean && make deviceclean
	wait
	echo -e ${cya}"Images deleted from OUT dir"${txtrst};
fi

lunch "$lunch_command"_"$device_codename"-"$build_type"
startTele
mkfifo reading
tee "${BUILDLOG}" < reading &
mka "${target_command}" -j$(nproc) > reading

# Record exit code after build
retVal=$?
timeEnd
statusBuild
sendLog "$BUILDLOG"

# Detecting file
FILENAME=$(cat $CDIR/out/var-file_name)
if [ "$target_command" = "nad" ]; then
    #FILEPATH=$(find "$OUT" -iname "${ROM_NAME}*${DEVICE}*zip")
    FILEPATH="$OUT/$FILENAME.zip"
elif [ "$target_command" = "bootimage" ]; then
    FILEPATH=$(find "$OUT" -iname "boot.img" 2>/dev/null)
else
    FILEPATH=$(find "$OUT" -iname "$target_command.apk" 2>/dev/null)
    sendTele "$FILEPATH"
    exit 0
fi

function gupload() {
     FILENAME=$(cat $CDIR/out/var-file_name)
     FILEPATH="$OUT/$FILENAME.zip"
     gdrive upload -p 1x8muGhGJh-2dQzihrrHPCSNrkcYEk_YG ${FILEPATH} | tee gdrv
}

if [ "$upload_to_sf" = "release" ]; then
    sshpass -p '' scp ${FILEPATH} ${SF_USER}@frs.sourceforge.net:/home/frs/project/${SF_PROJECT}/${DEVICE}/
    gupload
    sendInfo \
    "Uploaded to : https://sourceforge.net/projects/$SF_PROJECT/files/${DEVICE}/${FILENAME}.zip/download " \
    "MirrorLink  : https://drive.google.com/open?id=$(grep "Uploaded" gdrv | awk '{print $2}')"
fi

if [ "$upload_to_sf" = "test" ]; then
    sshpass -p '' scp ${FILEPATH} ${SF_USER}@frs.sourceforge.net:/home/frs/project/${SF_PROJECT_2}/test/nusantara
    gupload
    sendInfo \
    "Uploaded to : https://sourceforge.net/projects/$SF_PROJECT_TEST/files/test/nusantara/${FILENAME}.zip/download " \
    "MirrorLink  : https://drive.google.com/open?id=$(grep "Uploaded" gdrv | awk '{print $2}')"
fi

unset USE_GAPPS
unset USE_MICROG
unset USE_GMS
unset NAD_BUILD_TYPE
rm -f gdrv

exit 0

