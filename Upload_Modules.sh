#!/usr/bin/env bash

# Check and load required software (FreeSurfer, optionally FSL)
# This script is optional and mainly for cluster environments using modules

# Author: Mohammed Mudarris
# Email: mamudarris@gmail.com
# Description:
# Loads required modules if the 'module' command is available.
# Safe to run on systems without module support.

# Only run if module system exists
if command -v module &> /dev/null; then
    echo "Loading modules..."

    module load FreeSurfer/7.3.2
    module load FSL/6.0.6

else
    echo "No module system detected. Assuming software is already in PATH."
fi

# Check that recon-all exists
if ! command -v recon-all &> /dev/null; then
    echo "ERROR: recon-all not found. Make sure FreeSurfer is installed."
    exit 1
fi

echo "Environment ready."