#!/bin/bash

. ./common.sh

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ../env.sh
. ../log.sh
source /etc/profile

## check python3 is installed
python3_is_installed=$(get_python3_is_installed)
if [ "$FALSE" == "$python3_is_installed" ]; then
    log_warn "python3 is not installed! Please installed python3 first"
    exit
fi

## check npm is installed
npm_is_installed=$(get_npm_is_installed)
if [ "$FALSE" == "$npm_is_installed" ]; then
    log_warn "npm is not installed! Please installed npm first"
    exit
fi

## check jupyter is installed
jupyter_is_installed=$(get_jupyter_is_installed)
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
pip_bin=$PYTHON3_HOME/bin/pip3
python_bin=$PYTHON3_HOME/bin/python3
for conpoment in ${yum_conpoment_arr[@]}
do
    yum -y install $conpoment
done

$pip_bin install --upgrade pip
for conpoment in ${python3_conpoment_arr[@]}
do
    $pip_bin install $conpoment
done

for conpoment in ${jupyter_conpoment_arr[@]}
do
    log_info "Install jupyter conpoment: install $conpoment begin"
    #$pip_bin uninstall -y $conpoment
    if [ -n "$pip_proxy" ]; then
        $pip_bin install $conpoment -i $pip_proxy
    else
        $pip_bin install $conpoment
    fi
    log_info "Install jupyter conpoment: install $conpoment finish"
done

## install kernel
### 当前: 全部替换成 python3
for kernel in ${jupyter_kernel_arr[@]}
do
    log_info "Install jupyter kernel: install $kernel begin"
    $python_bin -m $kernel install
    log_info "Install jupyter kernel: install $kernel finish"
done

## config jupyter proxy
proxy_token_lines=`cat /etc/profile | grep CONFIGPROXY_AUTH_TOKEN | wc -l`
if [[ $proxy_token_lines -eq 0 ]]; then
    echo "export CONFIGPROXY_AUTH_TOKEN=$jupyter_proxy_token" >> /etc/profile
fi

## config jupyterhub
mkdir -p $jupyter_home/config

pushd $jupyter_home/config
jupyterhub_bin=$PYTHON3_HOME/bin/jupyterhub
jupyter_bin=$PYTHON3_HOME/bin/jupyter
rm -f jupyterhub_config.py
$jupyterhub_bin --generate-config

### basic
#### spawner
sed -i 's/#c.Spawner.cmd/c.Spawner.cmd/g' jupyterhub_config.py

#### auth
sed -i "s/.*c\.JupyterHub\.ip.*/c.JupyterHub.ip = '$jupyterhub_conf_bind_ip'/g" c
sed -i "s/.*c\.JupyterHub\.port.*/c.JupyterHub.port = $jupyterhub_conf_bind_port/g" jupyterhub_config.py
echo -e "\nc.PAMAuthenticator.service = '$jupyter_pam_file'\n" >> jupyterhub_config.py
jupyter_pam_path=/etc/pam.d/$jupyter_pam_file
echo '#%PAM-1.0' >> $jupyter_pam_path
echo 'auth    requisite pam_succeed_if.so uid >= 500 quiet' >> $jupyter_pam_path
echo 'auth    required  pam_unix.so nodelay' >> $jupyter_pam_path
echo 'account required  pam_unix.so' >> $jupyter_pam_path

### culler
echo "import sys
c.JupyterHub.services = [
    {
        'name': 'idle-culler',
        'admin': True,
        'command': [
            sys.executable,
            '-m', 'jupyterhub_idle_culler',
            '--timeout=$jupyter_spawner_timeout'
        ],
    }
]" >> jupyterhub_config.py

### scala
echo "c.Spawner.environment = {
        'SPARK_HOME': '/home/modules/spark-3.1.2'
}" >> jupyterhub_config.py

### R
yum -y install epel-release
yum -y update
yum -y install R

### memory and cpu limit
echo -e "\nc.Spawner.mem_limit = \"$jupyter_memory_limit\"\nc.Spawner.cpu_limit = $jupyter_cpu_limit\n" >> jupyterhub_config.py

### proxy
echo "
c.JupyterHub.cleanup_servers = False
c.ConfigurableHTTPProxy.should_start = False
c.ConfigurableHTTPProxy.auth_token = '$jupyter_proxy_token'
c.ConfigurableHTTPProxy.api_url = '$jupyter_proxy_address'
" >> jupyterhub_config.py

### install some useful extensions
$jupyter_bin contrib nbextension install --sys-prefix

#### auto complete
$jupyter_bin nbextension enable hinterland/hinterland --sys-prefix
#### show execute time
$jupyter_bin nbextension enable execute_time/ExecuteTime --sys-prefix
#### use numpy
$jupyter_bin nbextension enable snippets/main --sys-prefix

popd

## add at least two local account
for i in "${!juputer_local_username_arr[@]}"
do
    userdel ${juputer_local_username_arr[$i]} || true
    id -u ${juputer_local_username_arr[$i]} &>/dev/null || useradd ${juputer_local_username_arr[$i]}
    echo "${juputer_local_username_arr[$i]}:${jupyter_local_password_arr[$i]}" | chpasswd
    ### make home dir to avoid auto create home folder failed problem
    home_path=/home/${juputer_local_username_arr[$i]}
    mkdir -p $home_path
    chown -R ${juputer_local_username_arr[$i]}:${juputer_local_username_arr[$i]} $home_path
done

## copy jupyter systemd and start script
jupyter_script_path=$jupyter_home/scripts
mkdir -p $jupyter_script_path
cp start_jupyterhub.sh $jupyter_script_path
cp stop_jupyterhub.sh $jupyter_script_path
cp ../env.sh $jupyter_script_path
chmod -R 755 $jupyter_script_path

jupyter_service_file=/etc/systemd/system/jupyter.service
source /etc/profile
cp jupyterhub_systemd.conf $jupyter_service_file
format_path=`echo $PATH | sed 's/\//\\\\\//g'`
sed -i "s/{PATH}/$format_path/g" $jupyter_service_file
format_jupyter_home=`echo $jupyter_home | sed 's/\//\\\\\//g'`
sed -i "s/{JUPUTER_HOME}/$format_jupyter_home/g" $jupyter_service_file
chmod 755 $jupyter_service_file
systemctl daemon-reload

## start jupyterhub
### start_jupyterhub.sh

popd