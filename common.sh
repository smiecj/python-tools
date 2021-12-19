TRUE="True"
FALSE="False"

install_jq() {
    ## check jq is install
    jq_exec_ret=`jq --help 2>/dev/null || true`
    if [ -z "$jq_exec_ret" ]; then
        pushd /usr/local/bin && wget "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64" && mv jq-linux64 jq && chmod +x jq && popd
    fi
}

## check conda is installed
get_conda_is_installed() {
    local conda_env_get_ret=`cat /etc/profile | grep $conda_env_key_home`
    jq_exec_ret=`conda env list 2>/dev/null || true`
    if [ -z "$jq_exec_ret" ]; then
        echo "$FALSE"
        return
    fi
    echo "$TRUE"
}

## check npm is installed
get_npm_is_installed() {
    local jupyterhub_package_num=`[[ -n "$NODE_HOME" ]] && find $NODE_HOME/bin -name 'npm' 2>/dev/null | wc -l`
    if [ $jupyterhub_package_num -eq 0 ]; then
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

get_airflow_is_installed() {
    local conda_env_name=$1
    local jupyterhub_package_num=`ls -l $miniconda_install_path/envs/$conda_env_name/lib/python$python3_version/site-packages | grep 'airflow' | wc -l`
    if [ $jupyterhub_package_num -eq 0 ]; then
        echo "$FALSE"
        return
    fi
    echo "$TRUE"
}
