#!/bin/bash

cd $(dirname "$(readlink -f "$0")")

source args_for_build.sh

rm -rf builds
rm -rf builds_by_rev
rm -rf $ARG__CORE_BRANCH_NAME/build
rm -rf $ARG__CORE_BRANCH_NAME/scripts/ios_building_scripts/2_building_client_core/release

OIFS="$IFS"
IFS=$'\n'
for line in `find $ARG__CORE_BRANCH_NAME -type f ! -name '.DS_Store'`; do md5 $line; done > md5_client_ios_files.txt
for line in `find $ARG__NATIVE_BRANCH_NAME -type f ! -name '.DS_Store'`; do md5 $line; done >> md5_client_ios_files.txt
IFS="$OIFS"

md5 md5_client_ios_files.txt > md5_client_ios.txt
