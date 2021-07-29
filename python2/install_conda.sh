#!/bin/bash
#set -euxo pipefail

script_full_path=$(realpath $0)
home_path=`echo "{\"path\": \"$script_full_path\"}" | jq -c -r '.path | split("/") | .[:length-1] | join("/")'`
pushd $home_path

. ../env.sh
. ../log.sh
. ../common.sh

conda_is_installed=$(get_conda_is_installed)
if [ "$FALSE" == "$conda_is_installed" ]; then
    ## install conda
    rm -rf $miniconda_install_path
    ### remote old conda environment
    sed -i 's/.*CONDA.*//g' /etc/profile
    sed -i 's/.*conda.*//g' /etc/profile
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
else
    log_info "Conda has installed"
fi

popd