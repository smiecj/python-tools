update:
	git pull origin main

install_pip:
	sh python2/install_pip.sh 

install_jupyter:
	sh jupyter/install_jupyter.sh

uninstall_jupyter:
	sh jupyter/uninstall_jupyter.sh

install_python3:
	sh python3/install_python3.sh

install_conda:
	sh python2/install_conda.sh

test_conda_manager:
	sh python2/conda_manager_helper.sh get
	sh python2/conda_manager_helper.sh check py3 tensorflow
	sh python2/conda_manager_helper.sh update py3 tensorflow
	sh python2/conda_manager_helper.sh check py3 tensorflow 3.5.0

clean:
	find -name 'logs' | grep -v git | xargs rm -rf
	find -name 'packages' | xargs rm -rf
	find -maxdepth 1 -name 'jupyterhub*' | xargs rm -f

run_jupyter:
	sh jupyter/start_jupyterhub.sh

kill_jupyter:
	sh jupyter/stop_jupyterhub.sh

start_jupyter:
	service jupyter start

stop_jupyter:
	service jupyter stop

install_airflow:
	sh airflow/install_airflow.sh

run_airflow:
	sh airflow/start_airflow.sh

kill_airflow:
	sh airflow/stop_airflow.sh

start_airflow:
	service airflow start

stop_airflow:
	service airflow stop
