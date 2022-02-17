#!/usr/bin/env bash

set -eu

xhost +

sudo docker run \
    -it \
    --net=host \
    --rm \
    --runtime nvidia \
    -e DISPLAY=$DISPLAY \
    -v /tmp/argus_socket:/tmp/argus_socket \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ${HOME}/Downloads:/output \
    dsl.alpha:latest
