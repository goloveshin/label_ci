#!/bin/bash

cd $(dirname "$(readlink -f "$0")")

source args_for_build.sh

cd $ARG__CHECKOUT_PATH

# make_installer.py
cd scripts/client/dist
patch -p0 < $ARG__GLOBAL_SCRIPTS_PATH/jenkins/client-windows/patch/make_installer.patch
cd $ARG__CHECKOUT_PATH
