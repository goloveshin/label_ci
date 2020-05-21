#!/bin/bash

source /etc/profile

cd $(dirname "$(readlink -f "$0")")

source args_for_build.sh

rm -rf $ARG__CHECKOUT_PATH/$ARG__BUILD_DIR
rm -rf $ARG__CHECKOUT_PATH/$ARG__INSTALLER_DIR

OIFS="$IFS"
IFS=$'\n'
for line in `find $ARG__CHECKOUT_PATH -type f -not -name .DS_Store`; do md5 $line; done > md5_client_macos_files.txt
IFS="$OIFS"

md5 md5_client_macos_files.txt > md5_client_macos.txt
