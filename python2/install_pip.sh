#!/bin/bash
set -euxo pipefail

script_full_path=$(realpath $0)
home_path=`echo "{\"path\": \"$script_full_path\"}" | jq -c -r '.path | split("/") | .[:length-1] | join("/")'`
pushd $home_path

. ../env.sh
. ../log.sh

## check whether python is installed
### ref: https://stackoverflow.com/a/28256343
python_check_ret=`python -V 2>&1`
log_info "check version ret: $python_check_ret"
if [[ $python_check_ret =~ Python[[:space:]]2.* ]]; then
    python_version=`echo $python_check_ret | sed 's/.* //g'`
    log_info "Python version check success: $python_version"
elif [[ "$python_check_ret" =~ Python[[:space:]]3.* ]]; then
    log_info "Python version check failed: maybe install 3 version, need 2"
    exit
else
    log_info "Python version check failed: maybe not installed"
    exit
fi

if [ -d "$pkg_download_path" ]; then
    rm -rf $pkg_download_path
fi
mkdir $pkg_download_path

## Download to install packages
pushd $pkg_download_path
wget -O $setuptools_file -q "$setuptools_zip_url"
wget -O $ez_setup_file -q "$ez_setup_targz_url"
wget -O $pip_file -q "$pip_targz_url"

unzip $setuptools_file
tar -xzvf $ez_setup_file
tar -xzvf $pip_file

## List current folders and install those packages
sub_dir_arr=`ls -lrf -d */ | sed 's/ /\n/g' | sort -rn`
for dir in $sub_dir_arr
do
    pushd $dir
    python setup.py install
    popd
done

popd

popd

## finally: update pip
pip install --upgrade pip 2>&1 > /dev/null
