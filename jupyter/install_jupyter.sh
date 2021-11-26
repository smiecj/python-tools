#!/bin/bash

## check jq is install
jq_exec_ret=`jq --help 2>/dev/null || true`
if [ -z "$jq_exec_ret" ]; then
    cd /usr/local/bin && wget "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64" && mv jq-linux64 jq && chmod +x jq
fi

script_full_path=$(realpath $0)
home_path=`echo "{\"path\": \"$script_full_path\"}" | jq -c -r '.path | split("/") | .[:length-1] | join("/")'`
pushd $home_path

. ../env.sh
. ../log.sh
. ../common.sh

## check conda is installed
conda_is_installed=$(get_conda_is_installed)
if [ "$FALSE" == "$conda_is_installed" ]; then
    log_warn "Conda is not installed! Please installed conda first"
    exit
fi

## check npm is installed
npm_is_installed=$(get_npm_is_installed)
if [ "$FALSE" == "$npm_is_installed" ]; then
    log_warn "npm is not installed! Please installed npm first"
    exit
fi

## check jupyter is installed
jupyter_is_installed=$(get_jupyter_is_installed "$conda_env_name_python3")
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
source $miniconda_install_path/bin/activate $conda_env_name_python3
for conpoment in ${jupyter_conpoment_arr[@]}
do
    log_info "Install jupyter conpoment: install $conpoment begin"
    pip uninstall -y $conpoment
    if [ -n "$pip_proxy" ]; then
        pip install $conpoment -i $pip_proxy
    else
        pip install $conpoment
    fi
    log_info "Install jupyter conpoment: install $conpoment finish"
done

## install kernel
for kernel in ${jupyter_kernel_arr[@]}
do
    log_info "Install jupyter kernel: install $kernel begin"
    python -m $kernel install
    log_info "Install jupyter kernel: install $kernel finish"
done
conda deactivate

## config jupyter proxy
proxy_token_lines=`cat /etc/profile | grep CONFIGPROXY_AUTH_TOKEN | wc -l`
if [[ $proxy_token_lines -eq 0 ]]; then
    echo -e "\nexport CONFIGPROXY_AUTH_TOKEN=$jupyter_proxy_token"
fi

## config jupyterhub
mkdir -p $jupyter_home/config

pushd $jupyter_home/config
source $miniconda_install_path/bin/activate $conda_env_name_python3
rm -f jupyterhub_config.py
jupyterhub --generate-config

### basic
sed -i "s/.*c\.JupyterHub\.ip.*/c.JupyterHub.ip = '$jupyterhub_conf_bind_ip'/g" jupyterhub_config.py
sed -i "s/.*c\.JupyterHub\.port.*/c.JupyterHub.port = $jupyterhub_conf_bind_port/g" jupyterhub_config.py
echo -e "\nc.PAMAuthenticator.service = '$jupyter_pam_file'\n" >> jupyterhub_config.py

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
yum update
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
jupyter contrib nbextension install --sys-prefix

#### auto complete
jupyter nbextension enable hinterland/hinterland --sys-prefix
#### show execute time
jupyter nbextension enable execute_time/ExecuteTime --sys-prefix
#### use numpy
jupyter nbextension enable snippets/main --sys-prefix

conda deactivate
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

## start jupyterhub
### start_jupyterhub.sh

popd