#!/bin/bash

ps -ef | grep 'notebook' | grep -v grep | grep -v "stop_jupyter" | awk '{print $2}' | xargs -r kill -9
