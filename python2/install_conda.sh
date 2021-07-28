#!/bin/bash
#set -euxo pipefail

script_full_path=$(realpath $0)
home_path=`echo "{\"path\": \"$script_full_path\"}" | jq -c -r '.path | split("/") | .[:length-1] | join("/")'`
pushd $home_path

. ../env.sh
. ../log.sh

conda_env_get_ret=`cat /etc/profile | grep $conda_env_key_home`
conda_exec_ret=`conda env list`
conda_exec_ret_code=$?
if [ -z "$conda_env_get_ret" ] || [ 0 -ne $conda_exec_ret_code ]; then
    ## install conda
    rm -rf $miniconda_install_path
    ### todo: remove conda environment in the /etc/profile and last enters
    pushd $pkg_download_path
    conda_install_script=`echo "$conda_pkg_download_url" | sed 's/.*\///g'`
    wget -N -O $conda_install_script $conda_pkg_download_url
    bash $conda_install_script -b -p $miniconda_install_path

    ## add conda to environment
    echo -ne "\nexport $conda_env_key_home=$miniconda_install_path\nexport PATH=\$PATH:$conda_env_key_home/bin\n" >> /etc/profile
    source /etc/profile

    ## conda install env
    conda create -y --name $conda_env_name_python3 python=$python3_version
    conda config --set auto_activate_base false
    popd
fi

popd