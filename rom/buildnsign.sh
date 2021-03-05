#!/bin/bash

CDIR=$PWD
FILENAME=$(cat $CDIR/out/var-file_name)
export KEY_MAPPINGS=
export ANDROID_PW_FILE=
export device=
export buildtype=

# If we aren't in Jenkins, use the engineering tag
if [ -z "${BUILD_NUMBER}" ]; then
    export FILE_NAME_TAG=eng.$USER
else
    export FILE_NAME_TAG=$BUILD_NUMBER
fi

# Make package for distribution
source build/envsetup.sh
breakfast beryllium
make dist -j18 | tee

echo -e "Signing target files apks"
sign_target_files_apks -o -d $KEY_MAPPINGS \
    out/dist/nad_$device-target_files-$FILE_NAME_TAG.zip \
    $FILENAME-signed-target_files-$FILE_NAME_TAG.zip

echo -e "Generating signed install package"
ota_from_target_files -k $KEY_MAPPINGS/releasekey \
    --block ${INCREMENTAL} \
    $FILENAME-signed-target_files-$FILE_NAME_TAG.zip \
    $FILENAME-signed.zip
