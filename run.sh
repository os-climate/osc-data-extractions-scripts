#!/usr/bin/env bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2024 The Linux Foundation

docker run \
    -v "$PWD"/inputs:/osc/data-extraction/inputs:ro \
    -v "$PWD"/outputs:/osc/data-extraction/outputs \
    -ti osc/data-extraction-tools /bin/bash
