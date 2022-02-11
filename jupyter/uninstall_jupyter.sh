#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ../env.sh
. ../log.sh
. ../common.sh

find $miniconda_install_path/envs/$conda_env_name_python3 -name 'jupyter*' | xargs rm -rf