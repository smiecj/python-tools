#!/bin/bash

home_path=/home/coding/python-tools/python2
pushd $home_path

miniconda_install_path="/usr/local/miniconda2"
conda_script="Miniconda2-latest-Linux-x86_64.sh"
conda_expect="expect_install_conda.sh"
if [ $# -ge 1 ] && [ -n $1 ]; then
    miniconda_install_path=$1
fi

if [ ! -e $conda_script ]; then
    wget "https://repo.anaconda.com/miniconda/$conda_script"
fi

## expect not work, later find the reason
#expect $conda_expect $conda_script $miniconda_install_path

bash $conda_script -b -p $miniconda_install_path

popd