# python-tools
Some python environmenet init tools, used in centos system.


## contents
### python2
install_pip: python2 version install pip
install_conda: install conda

## how to use
### make install_pip
install pip for python2

### make install_python3
install python3 by yum

### make install_conda conda_type="conda/forge"
install miniconda, then we can manage our python environment more convenient

conda_type = conda: install [conda](https://docs.conda.io/en/latest/miniconda.html) (Anaconda version)
conda_type = forge: install [conda forge](https://conda-forge.org) (open source)

### make install_pip2pi
install [pip2pi](https://github.com/wolever/pip2pi) for pip server (pip2pi + httpd)

### make test_conda_manager
test conda manager(check and update)

### make install_jupyterhub
install jupyterhub on conda env, then we can use jupyterhub command to start it
default use notebook

### make install_jupyterlab
install jupyterlab and jupyterhub

### make install_airflow
install airflow

### clean
clean all temp folder, including logs