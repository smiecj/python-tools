#!/bin/bash
#set -euxo pipefail

. ./common.sh

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

## 通过 yum 方式安装 python3
yum -y install python3

## add python3 to environment
echo -e "\n# python" >> /etc/profile
echo "export $python3_env_key_home=/usr" >> /etc/profile
python3_lib_path=/usr/local/lib/`ll /usr/local/lib | grep python3 | sed 's/.* //g'`
echo "export $python3_lib_key_home=$python3_lib_path/site-packages" >> /etc/profile