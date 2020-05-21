#!/bin/bash

cd $(dirname "$(readlink -f "$0")")

source args_for_build.sh

rm -rf $ARG__CHECKOUT_PATH/$ARG__BUILD_DIR
rm -rf $ARG__CHECKOUT_PATH/$ARG__INSTALLER_DIR

OIFS="$IFS"
IFS=$'\n'
for line in `find $ARG__CHECKOUT_PATH -type f`; do md5sum $line; done > md5_server_files.txt
IFS="$OIFS"

md5sum md5_server_files.txt > md5_server.txt
