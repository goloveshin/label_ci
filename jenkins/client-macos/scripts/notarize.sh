#!/bin/bash

source /etc/profile

cd $(dirname "$(readlink -f "$0")")

source args_for_build.sh

cd $ARG__CHECKOUT_PATH/$ARG__INSTALLER_DIR/out

# from https://github.com/rednoah/notarize-app/blob/master/notarize-app

ASC_PROVIDER=$ARG__NOTARIZE_PROVIDER
ASC_USERNAME=$ARG__NOTARIZE_USERNAME
ASC_PASSWORD=$ARG__NOTARIZE_PASSWORD

BUNDLE_ID=$ARG__NOTARIZE_BUNDLE_ID
BUNDLE_PKG=$(find . -type f -name "*.dmg")


# create temporary files
NOTARIZE_APP_LOG=$(mktemp -t notarize-app)
NOTARIZE_INFO_LOG=$(mktemp -t notarize-info)

# delete temporary files on exit
function finish {
    rm "$NOTARIZE_APP_LOG" "$NOTARIZE_INFO_LOG"
}
trap finish EXIT


# submit app for notarization
if xcrun altool --notarize-app --primary-bundle-id "$BUNDLE_ID" --asc-provider "$ASC_PROVIDER" --username "$ASC_USERNAME" --password "$ASC_PASSWORD" -f "$BUNDLE_PKG" > "$NOTARIZE_APP_LOG" 2>&1; then
    cat "$NOTARIZE_APP_LOG"
    RequestUUID=$(awk -F ' = ' '/RequestUUID/ {print $2}' "$NOTARIZE_APP_LOG")

    # check status periodically
    while sleep 60 && date; do
        # check notarization status
        if xcrun altool --notarization-info "$RequestUUID" --asc-provider "$ASC_PROVIDER" --username "$ASC_USERNAME" --password "$ASC_PASSWORD" > "$NOTARIZE_INFO_LOG" 2>&1; then
            cat "$NOTARIZE_INFO_LOG"

            # once notarization is complete, run stapler and exit
            if ! grep -q "Status: in progress" "$NOTARIZE_INFO_LOG"; then
                xcrun stapler staple "$BUNDLE_PKG" # note: staple include validate
                spctl -a -t install -vv "$BUNDLE_PKG"
                exit $?
            fi
        else
            cat "$NOTARIZE_INFO_LOG" 1>&2
            exit 1
        fi
    done
else
    cat "$NOTARIZE_APP_LOG" 1>&2
    exit 1
fi
