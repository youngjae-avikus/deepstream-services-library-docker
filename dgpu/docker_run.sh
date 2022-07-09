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
    -v /tmp/.dsl/:/tmp/.dsl \
	-v ~/contrib/deepstream-services-library/:/opt/dsl/deepstream-services-library/ \
	-v ~/contrib/DeepStream-Yolo:/opt/dsl/DeepStream-Yolo/ \
	-v ~/contrib/yolov5:/opt/dsl/yolov5 \
	dsl:dgpu
