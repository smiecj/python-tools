#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_airflow.sh

nohup airflow webserver --port 8072 > $airflow_log_webserver 2>&1 &

nohup airflow scheduler > $airflow_log_scheduler 2>&1 &

popd