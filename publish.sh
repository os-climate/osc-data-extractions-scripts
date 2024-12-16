#/usr/bin/env bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2024 The Linux Foundation

source metadata

echo "Publishing docker image"
docker login
docker tag osc/$CONTAINER:$TAG $DOCKER_USER/$CONTAINER:$TAG
docker push $DOCKER_USER/$CONTAINER:$TAG
