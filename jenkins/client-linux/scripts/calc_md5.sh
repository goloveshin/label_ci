#!/bin/bash

cd $(dirname "$(readlink -f "$0")")

source args_for_build.sh

rm -rf $ARG__CHECKOUT_PATH/$ARG__BUILD_DIR
rm -rf $ARG__CHECKOUT_PATH/$ARG__INSTALLER_DIR

OIFS="$IFS"
IFS=$'\n'
for line in `find $ARG__CHECKOUT_PATH -type f`; do md5 $line; done > md5_client_linux_files.txt
IFS="$OIFS"

md5 md5_client_linux_files.txt > md5_client_linux.txt
