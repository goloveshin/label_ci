#!/bin/bash

cd $(dirname "$(readlink -f "$0")")

source args_for_build.sh

cd $ARG__CHECKOUT_PATH

