#!/bin/bash

source /etc/profile

cd $(dirname "$(readlink -f "$0")")

source args_for_build.sh

cd $ARG__CHECKOUT_PATH

XCODE_APP_NAME=Xcode

if [[ $ARG__COMPILER == "xcode-10" ]]; then
    XCODE_APP_NAME=Xcode
elif [[ $ARG__COMPILER == "xcode-11" ]]; then
    XCODE_APP_NAME=Xcode11
fi

# project.pbxproj
# TODO от CODE_SIGN_IDENTITY отказались, в дальнейшем убрать
gsed -i 's@CODE_SIGN_IDENTITY = \"Apple Development\";@CODE_SIGN_IDENTITY = \"iPhone Developer\";@g' $ARG__NATIVE_BRANCH_NAME/iosnative/IM.xcodeproj/project.pbxproj
gsed -i 's@]\" = \"iPhone Distribution\";@]\" = \"iPhone Developer\";@g' $ARG__NATIVE_BRANCH_NAME/iosnative/IM.xcodeproj/project.pbxproj

gsed -i "s@/Applications/Xcode.app@/Applications/${XCODE_APP_NAME}.app@g" $ARG__NATIVE_BRANCH_NAME/iosnative/IM.xcodeproj/project.pbxproj

# 2_building_client_core/build_client.sh
gsed -i "s@/Applications/Xcode.app@/Applications/${XCODE_APP_NAME}.app@g" $ARG__CORE_BRANCH_NAME/scripts/ios_building_scripts/2_building_client_core/build_client.sh
