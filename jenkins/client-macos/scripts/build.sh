#!/bin/bash

source /etc/profile

cd $(dirname "$(readlink -f "$0")")

source args_for_build.sh

cd $ARG__GLOBAL_SCRIPTS_PATH

./common.sh build-project \
	--target=$ARG__TARGET \
	--compiler=$ARG__COMPILER \
	--build-type=$ARG__BUILD_TYPE \
	--dep-path=$ARG__DEP_PATH \
	--pro-path=$ARG__CHECKOUT_PATH \
	--arg-file=$ARG__ARG_FILE
