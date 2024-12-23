<!--
[comment]: # SPDX-License-Identifier: Apache-2.0
[comment]: # SPDX-FileCopyrightText: 2024 The Linux Foundation
-->

# OS-Climate Data Extraction Scripts

## osc-data-extraction-scripts

Scripts to build/deploy the OS-Climate data extraction tooling

### Files

<!-- markdownlint-disable MD013 -->

| Name         | Description                                                                       |
| ------------ | --------------------------------------------------------------------------------- |
| Dockerfile   | Defines the steps required to build the data extraction tooling Docker container  |
| bootstrap.sh | Used to install Docker on a server instance [Debian/Ubuntu/Fedora/Amazon Linux]   |
| build.sh     | Thin shell script/wrapper to build the Docker container                           |
| metadata     | Contains variable definitions/parameters describing the Docker container          |
| publish.sh   | Thin shell script/wrapper publish the Docker container to a registry              |
| run.sh       | Thin shell script/wrapper ro run the Docker container                             |
| script.sh    | Script copied into the Docker container; uses GNU parallel to run data extraction |
| tag.sh       | Thin shell script/wrapper to tag the container with metadata                      |

<!-- markdownlint-enable MD013 -->

## script.sh

This is the primary script that runs/executes the data extraction toolset. It
is designed to run on a Linux instance and/or inside a docker container. It
enumerates the number of processor cores available and invokes the data
extraction Python tooling with GNU parallel to perform as many operations as
possible in parallel.

The script obtains a list of files selected for processing by using a wildcard
pattern match against a directory containing PDF files. Every file returned by
the pattern match is then passed to the Python tooling via GNU parallel.

```console
SELECTION="e15*.pdf"
```

Since Docker containers can artificially be restricted to a reduced number of
processor cores, Docker therefore provides a simple way to test the tool
performance when given a variable number of cores on which to run jobs.

The function that performs the processing is defined as:

```console
_process_files() {
 echo "Processing: $1"
 sleep 3
}
```

The source directory containing PDF files for ingestion is by default:

```console
SOURCE="inputs"
```

To invoke the data extraction tooling, simply replace the sleep statement with
the code required to ingest and process files. The shell script counts the
time elapsed (in seconds) to run the batch job, making it trivial to compare
the performance under different numbers of cores, versions of code, or other
metrics.

### License

All repository code/contents are licensed under the Apache-2.0 license
