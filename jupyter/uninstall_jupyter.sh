#!/bin/bash

script_full_path=$(realpath $0)
home_path=`echo "{\"path\": \"$script_full_path\"}" | jq -c -r '.path | split("/") | .[:length-1] | join("/")'`
pushd $home_path

. ../env.sh
. ../log.sh
. ../common.sh

find $miniconda_install_path/envs/$conda_env_name_python3 -name 'jupyter*' | xargs rm -rf