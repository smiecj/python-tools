#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ../env.sh
. ../log.sh
. ../common.sh
source /etc/profile

## check python3 is installed
python3_is_installed=$(get_python3_is_installed)
if [ "$FALSE" == "$python3_is_installed" ]; then
    log_warn "python3 is not installed! Please installed python3 first"
    exit
fi

## check airflow is installed
### todo: use absolute path as jupyter
airflow_is_installed=$(get_airflow_is_installed "$conda_env_name_python3")
if [ "$TRUE" == "$airflow_is_installed" ]; then
    log_warn "Airflow has installed!"
    exit
fi

log_info "Airflow is not installed, prepare to install now"

## install airflow

. ./env_airflow.sh

### prepare env
yum -y install python3-devel
python3 -m pip install --upgrade pip
pip3 install setuptools_rust
pip3 install wheel
pip3 install cpython
pip3 install cython
pip3 install numpy

useradd airflow || true
echo $airflow_username:$airflow_password | chpasswd

### install airflow
pip3 install "apache-airflow==${airflow_version}" --constraint "${requirement_url}" -i https://pypi.tuna.tsinghua.edu.cn/simple

### initialize the database
airflow db init

airflow users create \
    --username admin \
    --firstname Peter \
    --lastname Parker \
    --role Admin \
    --email spiderman@superhero.org

### copy start and stop script
airflow_script_bin_path=/usr/local/bin
cp env_airflow.sh $airflow_script_bin_path
cp start_airflow.sh $airflow_script_bin_path/airflowstart
chmod +x $airflow_script_bin_path/airflowstart
cp stop_airflow.sh $airflow_script_bin_path/airflowstop
chmod +x $airflow_script_bin_path/airflowstop

popd