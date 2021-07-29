#!/bin/bash

ps -ef | grep 'jupyter' | grep -v grep | grep -v "stop_jupyter" | awk '{print $2}' | xargs -r kill -9

ps -ef | grep 'configurable-http-proxy' | grep -v grep | awk '{print $2}' | xargs -r kill -9
