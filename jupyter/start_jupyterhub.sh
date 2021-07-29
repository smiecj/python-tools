#!/bin/bash

source /usr/local/miniconda2/bin/activate py3
nohup jupyterhub --config /home/modules/jupyter/config/jupyterhub_config.py > /dev/null 2>&1 &
conda deactivate