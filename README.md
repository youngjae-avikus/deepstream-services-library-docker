[![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/prominenceai/deepstream-services-library-docker?include_prereleases)](https://github.com/canammex-tech/deepstream-services-library/releases)
[![GitHub license](https://img.shields.io/github/license/Naereen/StrapDown.js.svg)](https://github.com/prominenceai/deepstream-services-library-docker/blob/master/LICENSE)
[![Ask Me Anything !](https://img.shields.io/badge/Ask%20me-anything-1abc9c.svg)](https://discord.com/channels/750454524849684540/750457019260993636)

# deepstream-services-library-docker
This repo contains Jetson and dGPU Dockerfiles and utility scripts for the [Deepstream Services Library](https://github.com/prominenceai/deepstream-services-library) (DSL). 

Important notes:
* Base images (Note: you can update the `ARG BASE_IMAGE` value in the `Dockerfile` to pull a different image).
  * Jetson - [`nvcr.io/nvidia/deepstream-l4t:6.0.1-triton`](https://docs.nvidia.com/metropolis/deepstream/dev-guide/text/DS_docker_containers.html#id2)
  * dGPU - [`nvcr.io/nvidia/deepstream:6.0.1-triton`](https://docs.nvidia.com/metropolis/deepstream/dev-guide/text/DS_docker_containers.html#id1)
  
* The [`deepstream-services-library`]((https://github.com/prominenceai/deepstream-services-library)) repo is cloned into `/opt/prominenceai/` collocated with `/opt/nvidia/`. **Note:** this is a temporary step. The `libdsl.so` can/will be pulled from GitHub directly in a future release.
* Additional build steps -- in interactive mode -- are required to build the `libdsl.so` once the container is running.
* **CAUTION: this repo is in the early stages of development -- please report issues!**

### Files
* `docker_setup.sh` - one time installation of Docker and its system dependencies.
* `docker_run.sh` - builds and runs the container in interactive mode - removes the container on exit.
* `Dockerfile` - Docker file used by the [Docker build command](#build-the-docker-image)

*... and many thanks to [@gigwegbe](https://github.com/gigwegbe) and [@youngjae-avikus](https://github.com/youngjae-avikus) for their contributions!*

## Contents
* [Install Docker and Docker Compose](#install-docker-and-docker-compose)
* [Set the default Docker runtime](#set-the-default-docker-runtime)
* [Add current user to docker group](#add-current-user-to-docker-group)
* [Re-login or reboot](#re-login-or-reboot)
* [Create a local Docker Registry](#create-a-local-docker-registry)
* [Build the Docker Image](#build-the-docker-image)
* [Build and run the Docker container](#build-and-run-the-docker-container)
* [Build the libdsl.so](#build-the-libdslso)
* [Install pyds module](#install-pyds-module)
* [Generate caffemodel engine files](#generate-caffemodel-engine-files-optional)
* [Complete Triton Setup](#complete-triton-setup-optional)
* [Commit your file changes](#commit-your-file-changes)
* [Deploy the image to the local Docker registry](#deploy-the-image-to-the-local-docker-registry)
* [Troubleshooting](#troubleshooting)

---

## Install Docker and Docker Compose
***Important note: NVIDIA requires a specific release of Docker.  See the [Troubleshooting](#troubleshooting) section if docker commands fail after updating your system with Software Updater.***

First, clone the DSL Docker GitHub repository.
```bash
git clone https://github.com/prominenceai/deepstream-services-library-docker
```
Navigate to the platform specific folder. For Jetson
```bash
cd deepstream-services-library-docker/jetson
```
or for dGPU
```bash
cd deepstream-services-library-docker/dgpu
```
Then make all sripts writable
```bash
chmod +x *.sh
```
Ensure you have `curl` installed by entering the following
```bash
curl --version
```
If not, install `curl` with the following command
```bash
sudo apt install curl
```
Then, run the one-time setup script to ensure that you have the correct versions of `docker` and `docker-compose` installed. 
```bash
./docker_setup.sh
```

## Set the default Docker runtime
Set the NVIDIA runtime as a default runtime in Docker. Update your `/etc/docker/daemon.json` file to read as follows.
```json
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
```
## Add current user to docker group
Add a current user to the docker group to use docker commands without sudo. You can refer to this guide: https://docs.docker.com/install/linux/linux-postinstall/. for more information.
```bash
sudo usermod -aG docker $USER ; newgrp docker
```

## Re-login or reboot
Your group membership needs to be re-evaluated. Either logout and log back in or reboot your device. 

## Create a local Docker Registry
Enter the following command to create a local Docker registry - one-time setup.
```bash
docker run -d -p 5000:5000 --restart=always --name registry registry:2
```

## Build the Docker Image
Navigate to the platform specific DSL Docker folder again. For Jetson
```bash
cd deepstream-services-library-docker/jetson
```
or for dGPU
```bash
cd deepstream-services-library-docker/dgpu
```
and build the Docker image with the following command. Make sure to add the current directory `.` as input.
```bash
docker build -t dsl:0 . 
```

## Build and run the Docker container
The Docker run script sets up the environment and runs the container with the below options:
```bash
 1 | docker run \
 2 |   -it \
 3 |   --rm \
 4 |   --net=host \
 5 |   --runtime nvidia \
 6 |   -e DISPLAY=$DISPLAY \
 7 |   -v /tmp/argus_socket:/tmp/argus_socket \
 8 |   -v /tmp/.X11-unix/:/tmp/.X11-unix \
 9 |   -v /tmp/.dsl/:/tmp/.dsl \
10 |   -v ${HOME}/Downloads:/output \
11 |   -w /opt/prominenceai/deepstream-services-library \
12 |   dsl:0

```
1. `docker run` Docker run command to build and run the `dsl:0` image in a container.
2. `-it` - run the container in interactive mode.
3. `--rm` - remove the container on exit.
4. `--net=host` - when a container is created, the container does not have an independent network (docker0) area and uses the host and the network together.
5. `--runtime nvidia` - redundant if set in `/etc/docker/daemon.json`.
6. `-e DISPLAY=$DISPLAY` - sets the display environment variable for the container.
7. `-v /tmp/argus_socket:/tmp/argus_socket` - argus tmp folder mapped into container.
8. `-v /tmp/.X11-unix/:/tmp/.X11-unix \` - X11 display folder mapped into container.
9. `-v /tmp/.dsl/:/tmp/.dsl` - DSL tmp folder, created on DSL installation, mapped into container.
10. `-v ${HOME}/Downloads:/output` - Downloads folder mapped into container
11. `-w /opt/prominenceai/deepstream-services-library` - working directory, update as desired.
12. `dsl:0` - name of the image to run, update as required.

Execute the Docker run script to build and run the container in interactive mode.
```bash
./docker_run.sh
```

## Build the `libdsl.so`
Once in interactive mode, copy and execute the following commands.
```bash
cd /opt/prominenceai/deepstream-services-library ; \
    make -j 4 ; \
    make install
```
**Note:** the library will be copied to `/usr/local/lib` once built.

## Install `pyds` module
To test the **custom_pph** python example (1uri_file_pgie_iou_tiler_osd_custom_pph_window.py), the `pyds` module must be installed in advance. Installation is available at the link [deepstream_python_apps](https://github.com/NVIDIA-AI-IOT/deepstream_python_apps). You can download and install whl from the [release page](https://github.com/NVIDIA-AI-IOT/deepstream_python_apps/releases)

For example, if environment is Nvidia Jetson, Ubuntu 18.04, Python 3.6, DeepStream SDK 6.0.1

```bash
wget pyds-1.1.1-py3-none-linux_aarch64.whl
pip3 install pyds-1.1.1-py3-none-linux_aarch64.whl
```

**Note:** For previous DeepStream versions, refer to the previous release

## Generate caffemodel engine files (optional)
Enable DSL logging if you wish to monitor the process (optional).
```bash
export GST_DEBUG=1,DSL:4
```
execute the python script in the `/opt/prominenceai/deepstream-services-library` root folder.
```bash
python3 make_caffemodel_engine_files.py
```
**Note:** this script can take several minutes to run.

The following files are generated (Jetson Nano versions by default)
```
/opt/nvidia/deepstream/deepstream/samples/models/Primary_Detector_Nano/resnet10.caffemodel_b8_gpu0_fp16.engine
/opt/nvidia/deepstream/deepstream/samples/models/Secondary_CarColor/resnet18.caffemodel_b8_gpu0_fp16.engine
/opt/nvidia/deepstream/deepstream/samples/models/Secondary_CarMake/resnet18.caffemodel_b8_gpu0_fp16.engine
/opt/nvidia/deepstream/deepstream/samples/models/Secondary_VehicleTypesresnet18.caffemodel_b8_gpu0_fp16.engine
```
Update the Primary detector path specification in the script to generate files for other devices. 

## Complete Triton Setup (optional)
To complete the Triton Server backend and model repository setup, navigate to the DeepStream samples root folder and execute the setup scripts with the following command.
```bash
cd /opt/nvidia/deepstream/deepstream/samples ; \
./triton_backend_setup.sh ; \
./prepare_ds_triton_model_repo.sh
```

**Note:** execution of the repo setup script can take serveral minutes.
## Commit your file changes.
**Caution** the `docker_run.sh` script includes the `-rm` flag in the run command to remove the container on exit. All changes you've made in the running container will be lost.

Use the `docker ps` command to list the running containers.
```bash
$ docker ps
CONTAINER ID   IMAGE                                      COMMAND                  CREATED          STATUS          PORTS                                       NAMES
da912760ce82   dsl:0                                      "/bin/bash"              42 minutes ago   Up 42 minutes                                               festive_brattain
26287d283d32   registry:2                                 "/entrypoint.sh /etc…"   3 hours ago      Up 3 hours      0.0.0.0:5000->5000/tcp, :::5000->5000/tcp   registry
605a54fa586d   mcr.microsoft.com/azureiotedge-agent:1.0   "/bin/sh -c 'exec /a…"   4 hours ago      Up 3 hours                                                  edgeAgent

```
Then commit the container by ID, using the image name.
```bash
docker commit da912760ce82 localhost:5000/dsl:latest
```
you can now safely `# exit` from interactive mode with all changes persisted.

Update your `docker_run.sh` script with the new `localhost:5000/dsl:latest` image name.

## Deploy the image to the local Docker registry
Use the following command to push the new image to the registry for deployment.
```bash
docker push localhost:5000/dsl:latest
```

---

## Troubleshooting
#### Docker errors after updating device software - including the latest version of Docker.
```bash
docker: Error response from daemon: failed to create shim: OCI runtime create failed: container_linux.go:380: 
starting container process caused: error adding seccomp filter rule for syscall clone3: permission denied: unknown.
```
NVIDIA requires a specific release of Docker - see https://github.com/dusty-nv/jetson-containers/issues/108

Solution, reinstall the correct version with the following commands.
```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install nvidia-docker2=2.8.0-1
```
