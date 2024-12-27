#!/usr/bin/env bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2024 The Linux Foundation

SUDO_CMD=$(which sudo)
WHOAMI=$(whoami)
if [ ! -x "$SUDO_CMD" ] || [ "$WHOAMI" = "root" ]; then
    SUDO_CMD=""
fi

if [ -f /etc/os-release ]; then
  # shellcheck disable=SC1091
  source /etc/os-release
fi

_install_docker() {

if [ "$NAME" = "Debian" ] || [ "$NAME" = "Debian GNU/Linux" ] || [ "$NAME" = "Ubuntu" ]; then
  for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
  $SUDO_CMD apt-get -y remove docker.io docker-doc docker-compose podman-docker containerd runc
  $SUDO_CMD apt-get -qq update
  $SUDO_CMD apt-get -qq install ca-certificates curl
  $SUDO_CMD install -m 0755 -d /etc/apt/keyrings
  $SUDO_CMD curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  $SUDO_CMD chmod a+r /etc/apt/keyrings/docker.asc
  # shellcheck disable=SC1091
  $SUDO_CMD echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  $SUDO_CMD apt-get -qq update
  $SUDO_CMD apt-get -qq install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  $SUDO_CMD apt-get install -qq wget vim less git nfs-common

elif [ "$NAME" = "Fedora" ]; then
  $SUDO_CMD dnf -y install dnf-plugins-core
  $SUDO_CMD dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  $SUDO_CMD dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  $SUDO_CMD dnf install -y wget curl vim less git nfs-utils

elif [ "$NAME" = "Amazon Linux" ]; then
  $SUDO_CMD yum update -y
  $SUDO_CMD yum install -y docker
  $SUDO_CMD usermod -a -G docker ec2-user
  $SUDO_CMD yum install -y wget vim less git nfs-utils amazon-efs-utils
fi

# Start at boot and run Docker
systemctl enable docker
systemctl start docker
}

# Install/run Docker
DOCKER_CMD=$(which docker >/dev/null 2>&1)
if [ ! -x "$DOCKER_CMD" ]; then
  _install_docker
fi
if ! (docker version > /dev/null 2>&1); then
  echo "Error: Docker failed to install/start"
  echo "Supported distributions: Ubuntu|Debian|Fedora|AmazonLinux"
  exit 1
fi

if [ ! -d /osc ]; then
  echo "Creating directory: /osc"
  $SUDO_CMD mkdir /osc
fi

if ! (grep -q '/osc' /etc/fstab);
then
  echo "Creating /etc/fstab entry for NFS mount"
  $SUDO_CMD echo "fs-0abca58dcce09a51a.efs.eu-west-2.amazonaws.com:/                        /osc         nfs4   defaults,noatime  0   0" >> /etc/fstab
fi

echo "Mounting EFS/NFS mount"
mount /osc
cd /osc/data-extraction || exit

CURRENT_DIR=$(pwd)
BASE_DIR=$(basename "$CURRENT_DIR")
if [ "$BASE_DIR" = "data-extraction" ]; then
  echo "Starting Ubuntu Docker container..."
  # Apple Silicon
  # docker run -v "$PWD":/data-extraction -ti --platform linux/arm64 ubuntu:22.04 /bin/bash /data-extraction/script.sh
  # docker run -v "$PWD":/data-extraction -ti --platform linux/arm64 ubuntu:22.04 /bin/bash
  #
  # x86/x64
  # docker run -v "$PWD":/data-extraction -ti ubuntu:22.04 /bin/bash /data-extraction/script.sh
  docker run -v "$PWD":/data-extraction -ti ubuntu:24.04 /bin/bash

else
    echo "Error: invoke the shell script from the data-extraction folder"; exit 1
fi

echo "Container and batch job stopped running"; exit 0
