#!/bin/bash

ps -ef | grep 'jupyter' | grep -v grep | grep -v "stop_jupyter" | grep -v "service jupyter" | grep -v "systemctl " | awk '{print $2}' | xargs --no-run-if-empty kill -9

ps -ef | grep 'configurable-http-proxy' | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9
