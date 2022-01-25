#!/bin/bash

script_full_path=$(realpath $0)
script_parent_path=$(dirname $script_full_path)

. $script_parent_path/env.sh

source /etc/profile

nohup $NODE_HOME/bin/node $NODE_HOME/bin/configurable-http-proxy --ip 0.0.0.0 --port 8000 --api-ip 127.0.0.1 --api-port $proxy_port --error-target http://127.0.0.1:$proxy_port/hub/error > /dev/null 2>&1 &

$miniconda_install_path/bin/conda run -n $conda_env_name_python3 nohup jupyterhub --config $jupyter_home/config/jupyterhub_config.py > /dev/null 2>&1 &
