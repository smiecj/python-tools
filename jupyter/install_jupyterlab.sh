#!/bin/bash

. ./common.sh

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ../env.sh
. ../log.sh
source /etc/profile

sh ./install_jupyterhub.sh

pushd $jupyter_home/config
sed -i "s/c.Spawner.cmd = \['jupyterhub-singleuser'\]/c.Spawner.cmd = \['jupyter-labhub'\]/g" jupyterhub_config.py
popd

popd