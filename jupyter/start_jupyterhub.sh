#!/bin/bash

. ./env.sh

nohup node $NODE_HOME/bin/configurable-http-proxy --ip 0.0.0.0 --port 8000 --api-ip 127.0.0.1 --api-port $proxy_port --error-target http://127.0.0.1:$proxy_port/hub/error > /dev/null 2>&1 &

conda run -n $conda_env_name_python3 nohup jupyterhub --config $jupyter_home/config/jupyterhub_config.py > /dev/null 2>&1 &
