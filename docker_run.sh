#!/usr/bin/env bash

set -eu

xhost +

docker run \
    -it \
    --rm \
    --net=host \
    --runtime nvidia \
    -e DISPLAY=$DISPLAY \
    -v /tmp/argus_socket:/tmp/argus_socket \
    -v /tmp/.X11-unix/:/tmp/.X11-unix \
    -v ${HOME}/Downloads:/output \
    -w /opt/prominenceai/deepstream-services-library \
    dsl:0

