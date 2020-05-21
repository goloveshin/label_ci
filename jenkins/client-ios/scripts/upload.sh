#!/bin/bash

source /etc/profile

cd $(dirname "$(readlink -f "$0")")

source args_for_build.sh

cd $ARG__CHECKOUT_PATH

REMOTE_ROOT_DIR=upload
ARCH_DIR=ios

BUILD_SUFFIX=
if [[ $ARG__BUILD_TYPE != "Release" ]]; then
    BUILD_SUFFIX="_${ARG__BUILD_TYPE_LOWERCASE}"
fi

NIGHT_PATH=${REMOTE_ROOT_DIR}/NightBuilds/client_${ARG__WHITE_LABEL}/${ARCH_DIR}/${ARG__CORE_BRANCH_NAME}/${ARG__NATIVE_BRANCH_NAME}/${ARG__CORE_BUILD_REV}__${ARG__NATIVE_BUILD_REV}${BUILD_SUFFIX}

OUTPUT_PATH=$(sed -n '2p' info.txt)

ncftp -u anonymous 192.168.111.80 <<< "rm -rf $NIGHT_PATH"
ncftpput -R -v -m -u anonymous 192.168.111.80 $NIGHT_PATH ${OUTPUT_PATH}/${ARG__BUILD_MODE}/${ARG__WHITE_LABEL}/*.ipa
