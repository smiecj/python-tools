TRUE="True"
FALSE="False"

## check conda is installed
get_conda_is_installed() {
    conda_exec_ret=`conda env list 2>/dev/null || true`
    if [ -z "$conda_exec_ret" ]; then
        echo "$FALSE"
        return
    fi
    echo "$TRUE"
}

## check python3 is installed
get_python3_is_installed() {
    python3_exec_ret=`python3 -V 2>/dev/null || true`
    if [ -z "$python3_exec_ret" ]; then
        echo "$FALSE"
        return
    fi
    echo "$TRUE"
}

## check npm is installed
get_npm_is_installed() {
    local jupyterhub_package_num=`[[ -n "$NODE_HOME" ]] && find $NODE_HOME/bin -name 'npm' 2>/dev/null | wc -l`
    if [[ $jupyterhub_package_num == "" ]] || [[ $jupyterhub_package_num == "0" ]]; then
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
    local jupyterhub_package_num=`ls -l $PYTHON3_LIB_HOME | grep 'jupyterhub' | wc -l`
    if [ $jupyterhub_package_num -eq 0 ]; then
        echo "$FALSE"
        return
    fi
    echo "$TRUE"
}

get_airflow_is_installed() {
    local airflow_package_num=`ls -l $PYTHON3_LIB_HOME | grep 'airflow' | wc -l`
    if [ $airflow_package_num -eq 0 ]; then
        echo "$FALSE"
        return
    fi
    echo "$TRUE"
}
