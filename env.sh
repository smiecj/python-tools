# python2 - pip

setuptools_zip_url=https://mirrors.bfsu.edu.cn/pypi/web/packages/7d/9a/ef929fd840f15be36daa94b35b2213bf257b2f511e2688875857d6391899/setuptools-2.0.zip
ez_setup_targz_url=https://mirrors.bfsu.edu.cn/pypi/web/packages/ba/2c/743df41bd6b3298706dfe91b0c7ecdc47f2dc1a3104abeb6e9aa4a45fa5d/ez_setup-0.9.tar.gz
pip_targz_url=https://mirrors.bfsu.edu.cn/pypi/web/packages/c4/44/e6b8056b6c8f2bfd1445cc9990f478930d8e3459e9dbf5b8e2d2922d64d3/pip-9.0.3.tar.gz

setuptools_file=setuptools.zip
ez_setup_file=ez_setup.tar.gz
pip_file=pip.tar.gz

pkg_download_path="packages"

## pip proxy
pip_proxy=

## conda
anaconda_version=4.11.0
conda_forge_version=4.12.0-0

### x86
conda_pkg_download_url=https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py38_$anaconda_version-Linux-x86_64.sh
conda_forge_download_url=https://mirrors.tuna.tsinghua.edu.cn/github-release/conda-forge/miniforge/Miniforge3-$conda_forge_version/Miniforge3-$conda_forge_version-Linux-x86_64.sh
system_arch=`uname -p`
if [[ "aarch64" == "$system_arch" ]]; then
    ### arm
    conda_pkg_download_url=https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py38_$anaconda_version-Linux-aarch64.sh
    conda_forge_download_url=https://mirrors.tuna.tsinghua.edu.cn/github-release/conda-forge/miniforge/Miniforge3-$conda_forge_version/Miniforge3-$conda_forge_version-Linux-aarch64.sh
fi

miniconda_install_path="/usr/local/miniconda"
conda_env_key_home="CONDA_HOME"
python3_env_key_home="PYTHON3_HOME"
python3_lib_key_home="PYTHON3_LIB_HOME"

conda_env_name_python3=py3
python3_version=3.8

# jupyter
## jupyter service
jupyter_service_file=/etc/systemd/system/jupyter.service
jupyter_app_env_key=JUPYTERHUB_SINGLEUSER_APP
jupyter_app_notebook=notebook.notebookapp.NotebookApp
jupyter_app_lab=jupyter_server.serverapp.ServerApp

## jupyter config
yum_conpoment_arr=("python3-zmq" "python3-devel" "libffi" "libffi-devel")
python3_conpoment_arr=("wheel" "setuptools_rust")
jupyter_conpoment_arr=("jupyter" "notebook" "jupyterhub" "jupyterlab" "PyHive" "jupyterhub-idle-culler" "spylon-kernel" "jupyter_contrib_nbextensions" "jupyterthemes")
jupyter_kernel_arr=("spylon_kernel")
npm_conpoment_arr=("configurable-http-proxy")

juputer_local_username_arr=("jupyter" "jupyter_test")
jupyter_local_password_arr=("jupyter@Qwer" "jupyter@test")

proxy_port=8102
jupyter_proxy_token=test_hub_123
jupyter_proxy_address=http://127.0.0.1:$proxy_port

## jupyterhub config
jupyter_home=/home/modules/jupyter

jupyterhub_conf_bind_ip=0.0.0.0
jupyterhub_conf_bind_port=8101

jupyter_pam_file=jupyterhub_pam

jupyter_spawner_timeout=3600
jupyter_memory_limit=1G
jupyter_cpu_limit=2

jupyterhub_log=$jupyter_home/jupyterhub.log