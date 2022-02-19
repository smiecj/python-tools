#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ../common.sh

. ../env.sh
. ../log.sh
source /etc/profile

sh ./install_jupyterhub.sh

pushd $jupyter_home/config
sed -i "s/c.Spawner.cmd = \['jupyterhub-singleuser'\]/c.Spawner.cmd = \['jupyter-labhub'\]/g" jupyterhub_config.py
sed -i "s/$jupyter_app_env_key=.*\"/$jupyter_app_env_key=$jupyter_app_lab\"/g" $jupyter_service_file
systemctl daemon-reload
popd

popd