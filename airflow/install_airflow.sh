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

### install airflow
pip3 install "apache-airflow==${airflow_version}" --constraint "${requirement_url}" -i https://pypi.tuna.tsinghua.edu.cn/simple

### initialize the database
airflow db init

airflow users create \
    --username $airflow_admin_username \
    --password $airflow_admin_password \
    --firstname $airflow_default_user_firstname \
    --lastname $airflow_default_user_lastname \
    --role $airflow_admin_role \
    --email $airflow_default_user_email

### copy start and stop script
airflow_script_bin_path=/usr/local/bin
cp -f env_airflow.sh $airflow_script_bin_path
cp start_airflow.sh $airflow_script_bin_path/airflowstart
chmod +x $airflow_script_bin_path/airflowstart
cp stop_airflow.sh $airflow_script_bin_path/airflowstop
chmod +x $airflow_script_bin_path/airflowstop

#### auto start at reboot
echo "@reboot $airflow_script_bin_path/airflowstart" >> /var/spool/cron/root

### log
mkdir -p $airflow_log_home
add_logrorate_task $airflow_log_webserver webserver
add_logrorate_task $airflow_log_scheduler scheduler

popd