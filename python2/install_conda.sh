#!/bin/bash
#set -euxo pipefail

. ./common.sh

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ../env.sh
. ../log.sh

conda_is_installed=$(get_conda_is_installed)
if [ "$FALSE" == "$conda_is_installed" ]; then
    ## install conda
    ### aarch 架构 需要先更新 glibc 才能成功安装 conda
    system_arch=`uname -p`
    if [ "aarch64" == "$system_arch" ]; then
        sh ./upgrade_glibc.sh
    fi

    rm -rf $miniconda_install_path
    ### remote old conda environment
    sed -i 's/.*CONDA.*//g' /etc/profile
    sed -i 's/.*conda.*//g' /etc/profile
    mkdir -p $pkg_download_path
    pushd $pkg_download_path
    conda_install_script=`echo "$conda_pkg_download_url" | sed 's/.*\///g'`
    wget --no-check-certificate -N -O $conda_install_script $conda_pkg_download_url
    bash $conda_install_script -b -p $miniconda_install_path

    ## add conda to environment
    echo -ne "\nexport $conda_env_key_home=$miniconda_install_path\nexport PATH=\$PATH:\$$conda_env_key_home/bin\n" >> /etc/profile
    source /etc/profile

    ## conda install env
    conda create -y --name $conda_env_name_python3 python=$python3_version
    conda config --set auto_activate_base false
    popd

    ## 设置pip 为国内源
    pip_conf_path=~/.pip
    mkdir -p $pip_conf_path
    rm -f $pip_conf_path/pip.conf
    echo '[global]' >> $pip_conf_path/pip.conf
    echo 'index-url = https://pypi.mirrors.ustc.edu.cn/simple/' >> $pip_conf_path/pip.conf
else
    log_info "Conda has installed"
fi

popd
source /etc/profile
