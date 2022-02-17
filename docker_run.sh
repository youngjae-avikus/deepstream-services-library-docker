#!/usr/bin/env bash

set -eu

xhost +

sudo docker run \
    -it \
    --net=host \
    --runtime nvidia \
    -e DISPLAY=$DISPLAY \
    -v /tmp/argus_socket:/tmp/argus_socket \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ${HOME}/Downloads:/output \
    -v ${HOME}/prominenceai:/prominenceai \
    -w /prominenceai \
    dsl.alpha:latest
