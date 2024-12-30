#!/usr/bin/env bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2024 The Linux Foundation

# OS-Climate / Data Extraction Team

# Script repository/location:
# https://github.com/os-climate/osc-data-extraction-scripts

### Bulk execution script ###

set -o pipefail
# set -vx

### Variables

# Folder location of input PDF files on EFS/NFS mount
SOURCE="inputs"
# Wildcard that selects the number of files to process
SELECTION="e15*.pdf"

### Functions

_process_files() {
    echo "Processing: $1"
    sleep 3
}
export -f _process_files

NPROC_CMD=$(which nproc)
if [ ! -x "$NPROC_CMD" ]; then
    echo "Error: nproc command not found in PATH"
    exit 1
fi
# Determined dynamically, but can be hard-wired to a fixed value
# Alternatively, the number available to Docker can be capped
THREADS=$($NPROC_CMD)

echo "OS-Climate / Data Extraction Team"
echo "Bulk execution script"

if [ ! -s /etc/localtime ]; then
  echo "Setting timezone"
  ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime
fi

if ! (which parallel > /dev/null 2>&1); then
  echo "Installing GNU parallel"
  apt-get update -qq
  apt-get install -qq parallel > /dev/null 2>&1
fi

echo "Parallel threads for batch processing: $THREADS"
START=$(date '+%s')
echo -n "Input files to process: "
# shellcheck disable=SC2012,SC2086
FILES=$(ls $SOURCE/$SELECTION)
echo "$FILES" | wc -l
# shellcheck disable=SC2012
echo "$FILES" | parallel -j "$THREADS" _process_files
END=$(date '+%s')
ELAPSED=$((END-START))
echo "Elapsed time in seconds: $ELAPSED"
echo "Batch job completed!"
