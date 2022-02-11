#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ../env.sh
. ../log.sh
. ../common.sh

## check conda is installed
conda_is_installed=$(get_conda_is_installed)
if [ "$FALSE" == "$conda_is_installed" ]; then
    log_warn "Conda is not installed! Please installed conda first"
    exit
fi

## check airflow is installed
airflow_is_installed=$(get_airflow_is_installed "$conda_env_name_python3")
if [ "$TRUE" == "$airflow_is_installed" ]; then
    log_warn "Airflow has installed!"
    exit
fi

log_info "Airflow is not installed, prepare to install now"

sh airflow_run_local.sh

popd