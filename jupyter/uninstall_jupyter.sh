#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ../env.sh
. ../log.sh
. ../common.sh
source /etc/profile

find $PYTHON3_LIB_HOME -name 'jupyter*' | xargs rm -rf