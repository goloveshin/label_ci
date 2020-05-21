#!/bin/bash

cd $(dirname "$(readlink -f "$0")")

source args_for_build.sh

cd $ARG__CHECKOUT_PATH

# build_client.py
cd scripts/client/dist

patch -p0 < $ARG__GLOBAL_SCRIPTS_PATH/jenkins/client-linux/patch/build_client.patch
