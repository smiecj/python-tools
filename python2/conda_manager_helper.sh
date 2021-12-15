#!/bin/sh
set -euxo pipefail

### conda manager server: https://github.com/smiecj/conda-manager

## check conda dependency and version
check_dependency() {
    ### if not pass version, then only check whether dependency is exist
    env_name=$1
    dependency=$2
    version=""
    if [ $# -eq 3 ]; then
        version=$3
    fi

    ### if pass version, check both existence and version
    conda_path=$(get_conda_path)
    check_ret=`$conda_path/envs/$env_name/bin/pip show $dependency 2>/dev/null || true`
    if [ -n "$version" ]; then
        check_ret=`echo "$check_ret" | grep -e "Version: $version\$" || true`
    fi
    if [ -n "$check_ret" ]; then
        echo "true"
    else
        echo "false"
    fi
}

## remove dependency
remove_dependency() {
    env_name=$1
    dependency=$2
    
    conda_path=$(get_conda_path)
    $conda_path/bin/conda remove -n env_name dependency
}

## update or install dependency by name and version
update_dependency() {
    env_name=$1
    dependency=$2
    version=""
    if [ $# -eq 3 ]; then
        version=$3
    fi
    # remove and reinstall it
    conda_path=$(get_conda_path)
    $conda_path/bin/conda remove -f -n $env_name $dependency || true

    if [ -z "$version" ]; then
        $conda_path/bin/conda install -y -n $env_name $dependency
    else
        $conda_path/bin/conda install -y -n $env_name $dependency==version
    fi
}

## package conda to zip file
package_conda() {
    target_ip=$1
    target_port=$2
    target_folder=$3
    
    tmp_conda_zip_path=/tmp/miniconda2.zip
    conda_path=$(get_conda_path)
    if [ -z "$conda_path" ]; then
        echo "conda path is not vaild: $conda_path"
        return 1
    fi
    zip -r $tmp_conda_zip_path $conda_path
    #scp $tmp_conda_zip_path -P$target_port root@target_ip:$target_folder
}

## common method: get conda install path
get_conda_path() {
    ### get by conda command or env
    local conda_path=""
    if [ -n "$CONDA_HOME" ]; then
        conda_path=$CONDA_HOME
    else
        conda_path=$(dirname $(dirname $(which conda)))
    fi
    echo $conda_path
}

main() {
    ## command:
    ### get conda path (to check conda is installed)
    ### add / update conda dependency
    ### remove conda dependency
    ### check dependency (regularlly check)
    ### backup (maybe leave this job to conda manager)
    command=$1
    shift
    args=$@

    case $command in
    (get)
        get_conda_path
        ;;
    (update)
        update_dependency $args
        ;;
    (remove)
        remove_dependency $args
        ;;
    (check)
        check_dependency $args
        ;;
    (*)
        echo "$command is not valid, please check!"
        exit 1
        ;;
    esac
}

main $@