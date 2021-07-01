#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

docker build -t barrelfish:git .
docker run -v "$SCRIPT_DIR":/home/builder/barrelfish -it barrelfish:git
