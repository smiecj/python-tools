#!/bin/bash

script_full_path=$(realpath $0)
home_path=`echo "{\"path\": \"$script_full_path\"}" | jq -c -r '.path | split("/") | .[:length-1] | join("/")'`
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

## check npm is installed
npm_is_installed=$(get_npm_is_installed)
if [ "$FALSE" == "$npm_is_installed" ]; then
    log_warn "npm is not installed! Please installed npm first"
    exit
fi

## check jupyter is installed
jupyter_is_installed=$(get_jupyter_is_installed "$conda_env_name_python3")
if [ "$TRUE" == "$jupyter_is_installed" ]; then
    log_warn "Jupyter has installed!"
    exit
fi

## install npm conpoment
for conpoment in ${npm_conpoment_arr[@]}
do
    npm install -g $conpoment
done

## install jupyter
source $miniconda_install_path/bin/activate $conda_env_name_python3
for conpoment in ${jupyter_conpoment_arr[@]}
do
    log_info "Install jupyter conpoment: install $conpoment begin"
    pip uninstall -y $conpoment
    pip install $conpoment
    log_info "Install jupyter conpoment: install $conpoment finish"
done
conda deactivate

## config jupyterhub
mkdir -p $jupyter_conf_home/config

pushd $jupyter_conf_home/config
source $miniconda_install_path/bin/activate $conda_env_name_python3
rm jupyterhub_config.py
jupyterhub --generate-config
sed -i "s/.*c\.JupyterHub\.ip.*/c.JupyterHub.ip = '$jupyterhub_conf_bind_ip'/g" jupyterhub_config.py
sed -i "s/.*c\.JupyterHub\.port.*/c.JupyterHub.port = $jupyterhub_conf_bind_port/g" jupyterhub_config.py
conda deactivate
popd

## start jupyterhub
### start_jupyterhub.sh

popd