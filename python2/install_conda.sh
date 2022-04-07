#!/bin/bash
#set -euxo pipefail

conda_type="conda"
if [ $# -gt 0 ] && [ -n $1 ]; then
    conda_type=$1
fi

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ../common.sh

. ../env.sh
. ../log.sh

## forge: conda 的开源版本
if [ "forge" == "$conda_type" ]; then
    conda_pkg_download_url=$conda_forge_download_url
fi

conda_is_installed=$(get_conda_is_installed)
if [ "$FALSE" == "$conda_is_installed" ]; then
    ## install conda
    ### centos7 aarch 架构 需要先更新 glibc 才能成功安装 conda
    system_arch=`uname -p`
    centos_version=`cat /etc/redhat-release | sed 's/.*release //g' | sed 's/ .*//g'`
    if [[ "aarch64" == "$system_arch" ]] && [[ $centos_version =~ 7.* ]] && [[ "forge" != "$conda_type" ]] ; then
       sh ./upgrade_glibc.sh
    fi

    rm -rf $miniconda_install_path
    ### remote old conda environment
    sed -i 's/.*CONDA.*//g' /etc/profile
    sed -i 's/.*conda.*//g' /etc/profile
    mkdir -p $pkg_download_path
    pushd $pkg_download_path
    conda_install_script=`echo "$conda_pkg_download_url" | sed 's/.*\///g'`
    curl -LO $conda_pkg_download_url
    bash $conda_install_script -b -p $miniconda_install_path

    ## conda install python3 env
    $miniconda_install_path/bin/conda create -y --name $conda_env_name_python3 python=$python3_version
    $miniconda_install_path/bin/conda config --set auto_activate_base false
    popd

    ## add conda and python3 to environment
    ### 注意 python 本身不要设置在环境变量中，否则可能会导致 yum 无法执行
    python3_home_path=$miniconda_install_path/envs/$conda_env_name_python3
    python3_lib_path=$miniconda_install_path/envs/$conda_env_name/lib/python$python3_version/site-packages
    echo -e "\n# conda & python" >> /etc/profile
    echo "export $conda_env_key_home=$miniconda_install_path" >> /etc/profile
    echo "export $python3_env_key_home=$python3_home_path" >> /etc/profile
    echo "export $python3_lib_key_home=$python3_lib_path" >> /etc/profile
    echo "export PATH=\$PATH:\$$python3_env_key_home/bin:\$$conda_env_key_home/bin" >> /etc/profile

    ### python3 soft link
    rm -f /usr/bin/python3*
    rm -f /usr/bin/pip3*
    ln -s $python3_home_path/bin/python3 /usr/bin/python3
    ln -s $python3_home_path/bin/pip3 /usr/bin/pip3
    source /etc/profile

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
