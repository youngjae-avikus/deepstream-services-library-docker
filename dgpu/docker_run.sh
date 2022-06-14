#!/usr/bin/env bash

ROOT_DIR=$1

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
	-v ${ROOT_DIR}/deepstream-services-library/:/opt/dsl/deepstream-services-library/ \
	-v ${ROOT_DIR}/DeepStream-Yolo:/opt/dsl/DeepStream-Yolo/ \
	-v ${ROOT_DIR}/yolov5:/opt/dsl/yolov5 \
	-v ${ROOT_DIR}/aiboat-nas-jetson-inference/data:/opt/dsl/data \
	dsl:dgpu_v0.0.1
