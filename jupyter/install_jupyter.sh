#!/bin/bash

pkg_folder_name="package"



## install conda
conda_env_line=`echo /etc/profile | grep CONDA_HOME`
if [ -z $conda_env_line ]; then
    wget $conda_pkg_download_url

## install jupyter