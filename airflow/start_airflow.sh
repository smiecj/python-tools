#!/bin/bash

CONDA_ENV=py3

source $CONDA_HOME/bin/activate $CONDA_ENV

nohup airflow webserver --port 8072 > /dev/null 2>&1 &

nohup airflow scheduler > /dev/null 2>&1 &

conda deactivate

popd