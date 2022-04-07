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
sed -i "s/# c.Spawner.cmd/c.Spawner.cmd/g" jupyterhub_config.py
sed -i "s/c.Spawner.cmd = \['jupyterhub-singleuser'\]/c.Spawner.cmd = \['jupyter-labhub'\]/g" jupyterhub_config.py
sed -i "s/$jupyter_app_env_key=.*\"/$jupyter_app_env_key=$jupyter_app_lab\"/g" $jupyter_service_file
systemctl daemon-reload
popd

## 安装 jupyterlab lsp
### https://github.com/jupyter-lsp/jupyterlab-lsp
### https://github.com/jupyterlab/jupyterlab/issues/2972
pip_bin=$PYTHON3_HOME/bin/pip3
jupyter labextension install @krassowski/jupyterlab-lsp 
$pip_bin install jupyterlab-lsp
$pip_bin install jupyter-lsp
$pip_bin install git+https://github.com/krassowski/python-language-server.git@main
$PYTHON3_HOME/bin/jupyter server extension enable --user --py jupyter_lsp

## todo: 安装其他 jupyterlab 插件

### continuousHinting 自动补全 需要手动打开
### Settings -> Advanced Settings Editor -> Code Completion -> set continuousHinting = true

popd