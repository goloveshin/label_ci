#!/bin/bash

cd $(dirname "$(readlink -f "$0")")

source args_for_build.sh

cd $ARG__CHECKOUT_PATH

REMOTE_ROOT_DIR=upload
PLATFORM_DIR=
ARCH_DIR=

if [[ $ARG__TARGET == "server-for-debian-8-64" ]]; then
    PLATFORM_DIR="debian-8"
    ARCH_DIR="x64"
elif [[ $ARG__TARGET == "server-for-debian-9-64" ]]; then
    PLATFORM_DIR="debian-9"
    ARCH_DIR="x64"
elif [[ $ARG__TARGET == "server-for-windows-32" ]]; then
    PLATFORM_DIR="windows"
    ARCH_DIR="x86"
elif [[ $ARG__TARGET == "server-for-windows-64" ]]; then
    PLATFORM_DIR="windows"
    ARCH_DIR="x64"
fi 

BUILD_SUFFIX=
if [[ $ARG__BUILD_TYPE != "Release" ]]; then
    BUILD_SUFFIX="_${ARG__BUILD_TYPE_LOWERCASE}"
fi

APPLICATION_SUFFIX=
if [[ $ARG__APPLICATION != "server" ]]; then
    APPLICATION_SUFFIX="_${ARG__APPLICATION//-/_}"
fi

NIGHT_PATH=${REMOTE_ROOT_DIR}/NightBuilds/server/${PLATFORM_DIR}/${ARCH_DIR}/${ARG__BRANCH_NAME}/${ARG__BUILD_REV}${BUILD_SUFFIX}${APPLICATION_SUFFIX}

cd $ARG__INSTALLER_DIR

ncftp -u anonymous 192.168.111.80 <<< "rm -f $NIGHT_PATH/$INSTALLER_FILE"
ncftpput -v -m -u anonymous 192.168.111.80 $NIGHT_PATH $ARG__INSTALLER_FILE
