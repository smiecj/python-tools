#!/bin/bash

ps -ef | grep 'jupyterhub_config' | grep -v grep | grep -v "stop_jupyter" | awk '{print $2}' | xargs --no-run-if-empty kill -9

ps -ef | grep 'jupyterhub_idle_culler' | grep -v grep | grep -v "stop_jupyter" | awk '{print $2}' | xargs --no-run-if-empty kill -9

ps -ef | grep 'jupyterhub-singleuser' | grep -v grep | grep -v "stop_jupyter" | awk '{print $2}' | xargs --no-run-if-empty kill -9

ps -ef | grep 'configurable-http-proxy' | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9
