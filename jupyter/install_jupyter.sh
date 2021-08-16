#!/bin/bash

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

## config jupyterhub
mkdir -p $jupyter_home/config

pushd $jupyter_home/config
source $miniconda_install_path/bin/activate $conda_env_name_python3
rm -f jupyterhub_config.py
jupyterhub --generate-config
sed -i "s/.*c\.JupyterHub\.ip.*/c.JupyterHub.ip = '$jupyterhub_conf_bind_ip'/g" jupyterhub_config.py
sed -i "s/.*c\.JupyterHub\.port.*/c.JupyterHub.port = $jupyterhub_conf_bind_port/g" jupyterhub_config.py
echo -e "\nc.PAMAuthenticator.service = '$jupyter_pam_file'\n" >> jupyterhub_config.py
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
echo -e "\nc.Spawner.mem_limit = \"$jupyter_memory_limit\"\nc.Spawner.cpu_limit = $jupyter_cpu_limit\n" >> jupyterhub_config.py
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
    chown ${juputer_local_username_arr[$i]}:${juputer_local_username_arr[$i]} $home_path
done

## start jupyterhub
### start_jupyterhub.sh

popd