#!/bin/bash

. ./env_airflow.sh

nohup airflow webserver --port 8072 > /dev/null 2>&1 &

nohup airflow scheduler > /dev/null 2>&1 &

popd