#!/bin/bash

source /etc/profile

cd $(dirname "$(readlink -f "$0")")

source args_for_build.sh

cd $ARG__CHECKOUT_PATH/$ARG__INSTALLER_DIR/out

ASC_USERNAME=$ARG__NOTARIZE_USERNAME
ASC_PASSWORD=$ARG__NOTARIZE_PASSWORD

BUNDLE_PKG=$(find . -type f -name "*.dmg")

xcrun altool --validate-app --file $BUNDLE_PKG -t osx --username "$ASC_USERNAME" --password "$ASC_PASSWORD"

xcrun altool --upload-app --file $BUNDLE_PKG -t osx --username "$ASC_USERNAME" --password "$ASC_PASSWORD"