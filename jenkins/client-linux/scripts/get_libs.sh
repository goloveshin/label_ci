#!/bin/bash

cd $(dirname "$(readlink -f "$0")")

source args_for_build.sh

cd $ARG__GLOBAL_SCRIPTS_PATH

./common.sh get-libs \
	--target=$ARG__TARGET \
	--compiler=$ARG__COMPILER \
	--build-type=$ARG__BUILD_TYPE \
	--dep-path=$ARG__DEP_PATH \
	--out-file=$ARG__OUT_FILE