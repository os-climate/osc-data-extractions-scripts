#!/usr/bin/env bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2024 The Linux Foundation

source metadata

IMAGE=$(docker image ls | grep "$CONTAINER" | awk '{print $3}')
if [ -n "$IMAGE" ]; then
    docker image rmi "$IMAGE" --force > /dev/null 2>&1
fi

if [ $# -eq 0 ]; then
    IMAGE=$(docker image ls | grep '<none>' | awk '{print $3}')
elif [ $# -eq 1 ]; then
    IMAGE="$1"
else
    echo "Usage:  tag.sh [image]"
    exit 1
fi

docker image tag "$IMAGE" osc/$CONTAINER:$TAG
