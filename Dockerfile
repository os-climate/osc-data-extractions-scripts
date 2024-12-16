# SPDX-License-Identifier: Apache-2.0
# Copyright 2024 The Linux Foundation

# Data Extraction Team Dockerfile

FROM python:3.11
ENV WORKDIR=/osc/data-extraction/
WORKDIR $WORKDIR
RUN pip install -q --upgrade pip

# Refresh package database
RUN apt-get update

# Install GNU Parallel
RUN apt-get -y install parallel vim less

# Create directories
RUN mkdir -p /osc/data-extraction/inputs
RUN mkdir -p /osc/data-extraction/outputs

# Install data extraction tooling
RUN python3 -m pip install -q \
osc-inception-converter \
osc-rule-based-extractor \
osc-transformer-based-extractor \
osc-transformer-presteps

COPY script.sh .

# ENTRYPOINT ["/osc/data-extraction/script.sh"]
