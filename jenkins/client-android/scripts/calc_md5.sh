#!/bin/bash

cd $(dirname "$(readlink -f "$0")")

source args_for_build.sh

rm -rf WORKING_DIR

OIFS="$IFS"
IFS=$'\n'
for line in `find $ARG__CHECKOUT_PATH -type f`; do md5sum $line; done > md5_client_android_files.txt
IFS="$OIFS"

md5sum md5_client_android_files.txt > md5_client_android.txt
