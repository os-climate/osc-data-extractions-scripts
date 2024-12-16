#/usr/bin/env bash

# SPDX-License-Identifier: Apache-2.0
# Copyright 2024 The Linux Foundation

set -o pipefail

# Debug script
# set -vx

PYTHON_VERSION="3.11"
SOURCE_DIR=/data-extraction/pdf
OUTPUT_DIR=/data-extraction/output
VENV_DIR=venv/osc-data-extraction

### SSH setup for remote access to Data Extraction Team / AWS server instance

# ssh -i data-extraction-bulk-testing-keypair.pem user@18.175.236.103

# Add to ~/.ssh/config
# Host 18.175.236.103
#   User ec2-user
#   IdentityFile ~/.ssh data-extraction-bulk-testing-keypair.pem

### Script prerequisites

CURRENT_DIR=$(pwd)
BASE_DIR=$(basename "$CURRENT_DIR")
if [ "$BASE_DIR" != "data-extraction" ]; then
	if !(cd /data-extraction); then
		echo "Could not change into mapped container directory"
		exit 1
	fi
fi

NPROC_CMD=$(which nproc)
if [ -x "$NPROC_CMD" ]; then
	THREADS=$($NPROC_CMD)
else
	echo "Error: nproc not found in PATH"; exit 1
fi

### Functions

_process_files() {
	echo "Processing $1"
}

_install_packages() {

	echo "Attempting to install required software dependencies..."

	if [ $(uname) = "Darwin" ]; then
		BREW_CMD=$(which brew)
		if [ -x "$BREW_CMD" ]; then
			brew update
			brew install parallel ncurses pyenv
			alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'
			echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
			echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
			echo 'eval "$(pyenv init -)"' >> ~/.zshrc
			source ~/.zshrc
		else
			echo "Error: install homebrew or manually add/install GNU parallel"; exit 1
		fi

	elif [ $(uname) = "Linux" ]; then
		echo "Updating package database..."
		apt-get -qq update
		echo "Setting timezone..."
		DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -qq install tzdata
		echo "Installing required packages..."
		apt-get install -y -q parallel curl git make build-essential dialog libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl python3 python3-pip
		echo "Installing pyenv..."
		curl https://pyenv.run | bash
		export PYENV_ROOT="$HOME/.pyenv"
		[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
		echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
		echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
		source ~/.profile
		eval "$(pyenv init -)"
		eval "$(pyenv virtualenv-init -)"
		pyenv install "$PYTHON_VERSION"
		pyenv global "$PYTHON_VERSION"
	fi
}

_install_osc_tools() {
	echo "Installing data extraction tools..."
	python3 -m pip install -q osc-transformer-presteps
}

# Make function available to GNU parallel
export -f _process_files

### Script

_install_packages
# Activate/source Python virtual environment
if [ ! -f "$VENV_DIR/bin/activate" ];then
	echo "Setting up virtual environment..."
	python3 -m venv "$VENV_DIR"
fi
source "$VENV_DIR/bin/activate"
echo "Upgrading Python pip..."
pip install -q --upgrade pip
_install_osc_tools

DATA_EX_TOOL=osc-transformer-based-extractor
DATA_EX_CMD=$(which "$DATA_EX_TOOL" > /dev/null 2>&1)

echo "Parallel threads for batch processing: $THREADS"
find "$SOURCE_DIR" -name '0ef3b*.pdf' | "$PARALLEL_CMD" -j "$THREADS" _process_files
