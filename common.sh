TRUE="True"
FALSE="False"

## check conda is installed
get_conda_is_installed() {
    local conda_env_get_ret=`cat /etc/profile | grep $conda_env_key_home`
    local conda_exec_ret=`conda env list`
    local conda_exec_ret_code=$?
    if [ -z "$conda_env_get_ret" ] || [ 0 -ne $conda_exec_ret_code ]; then
        echo "$FALSE"
        return
    fi
    echo "$TRUE"
}

## check npm is installed
get_npm_is_installed() {
    local npm_exec_ret=`npm version`
    local npm_exec_ret_code=$?
    if [ 0 -ne $npm_exec_ret_code ]; then
        echo "$FALSE"
        return
    fi
    echo "$TRUE"
}

## check jupyter is installed
### because conda < 4.8.4 will set all command return code to 0, we cannot use exit code 
### to judge jupyter is installed.
### Use site-packages folder to judge jupyterhub is installed
### refer: https://github.com/conda/conda/issues/9599
get_jupyter_is_installed() {
    local conda_env_name=$1
    local jupyterhub_package_num=`ls -l $miniconda_install_path/envs/$conda_env_name/lib/python$python3_version/site-packages | grep 'jupyterhub' | wc -l`
    if [ $jupyterhub_package_num -eq 0 ]; then
        echo "$FALSE"
        return
    fi
    echo "$TRUE"
}
