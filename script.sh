#/usr/bin/env bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2024 The Linux Foundation

# OS-Climate / Data Extraction Team

### Bulk execution script ###

set -o pipefail
# set -vx

### Variables

SOURCE="inputs"
DESTINATION="outputs"
SELECTION="e15*.pdf"

### Functions

_process_files() {
  echo "Processing: $1"
  sleep 3
}
export -f _process_files

NPROC_CMD=$(which nproc)
if [ -x "$NPROC_CMD" ]; then
	THREADS=$($NPROC_CMD)
else
	echo "Error: nproc command not found in PATH"
	exit 1
fi

echo "OS-Climate / Data Extraction Team"
echo "Bulk execution script"
echo "Parallel threads for batch processing: $THREADS"
START=$(date '+%s')
echo -n "Input files to process: "; ls $SOURCE/$SELECTION | wc -l
ls $SOURCE/$SELECTION | parallel -j "$THREADS" _process_files
END=$(date '+%s')
ELAPSED=$((END-START))
echo "Elapsed time in seconds: $ELAPSED"
echo "Batch job completed!"
