#!/bin/bash

source /etc/profile

cd $(dirname "$(readlink -f "$0")")

source args_for_build.sh

cd $ARG__CHECKOUT_PATH

QT_MAJOR_VERSION=5
TEST_DIR=beta-test

if [[ $ARG__BUILD_MODE == "TEST-FUTURE" ]]; then
    TEST_DIR=beta-test-future
fi

REMOTE_ROOT_DIR=upload
ARCH_DIR=macosx

BUILD_SUFFIX=
if [[ $ARG__BUILD_TYPE != "Release" ]]; then
    BUILD_SUFFIX="_${ARG__BUILD_TYPE_LOWERCASE}"
fi

NOTARIZE_SUFFIX=
if [[ -n $ARG__NOTARIZE_PROVIDER ]]; then
    NOTARIZE_SUFFIX="_notarize"
fi

NIGHT_PATH=${REMOTE_ROOT_DIR}/NightBuilds/client_${ARG__WHITE_LABEL}/${ARCH_DIR}/x64/qt${QT_MAJOR_VERSION}/${ARG__BRANCH_NAME}/${ARG__BUILD_REV}${BUILD_SUFFIX}${NOTARIZE_SUFFIX}
TEST_PATH=${REMOTE_ROOT_DIR}/NightBuilds/client_${ARG__WHITE_LABEL}/${ARCH_DIR}/x64/${TEST_DIR}
PACKAGE_BASENAME=${ARG__WHITE_LABEL}_darwin_x64_qt${QT_MAJOR_VERSION}_r${ARG__BUILD_REV}

if [[ $ARG__BUILD_MODE != "TEST-FUTURE" ]]; then
    ncftp -u anonymous 192.168.111.80 <<< "rm -rf $NIGHT_PATH"
    ncftpput -R -v -m -u anonymous 192.168.111.80 $NIGHT_PATH ${ARG__INSTALLER_DIR}/out/*
fi

if [[ $ARG__BUILD_MODE == "TEST" || $ARG__BUILD_MODE == "TEST-FUTURE" ]]; then
    TMP_PATH=${ARG__INSTALLER_DIR}/out/tmp1

    mkdir -p $TMP_PATH

    cp $ARG__INSTALLER_DIR/out/${PACKAGE_BASENAME}.dmg         	$TMP_PATH/${ARG__WHITE_LABEL}.dmg
    cp $ARG__INSTALLER_DIR/out/${PACKAGE_BASENAME}_updates.7z   $TMP_PATH/updates.7z
    cp $ARG__INSTALLER_DIR/out/darvinversion.info              	$TMP_PATH/darvinversion.info
    cp $ARG__INSTALLER_DIR/out/${ARG__WHITE_LABEL}.ini          $TMP_PATH/${ARG__WHITE_LABEL}.ini

    ncftp -u anonymous 192.168.111.80 <<< "rm -rf $TEST_PATH"
    ncftpput -R -v -m -u anonymous 192.168.111.80 $TEST_PATH $TMP_PATH/*
fi
