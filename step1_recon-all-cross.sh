#!/usr/bin/env bash

# Author: Mohammed Mudarris
# email: mamudarris@gmail.com
# Last updated: 20260318
# Description: recon-all cross-sectional run for BIDS formatted data. This is the first step of a longitudinal preprocessing pipeline. 
# Runs FreeSurfer recon-all (cross-sectional) for a list of T1-weighted images.
# Assumes a BIDS-like naming structure (e.g., sub-XX_ses-YY_T1w.nii.gz).
#
# This script:
# - Reads a list of T1 files
# - Extracts subject IDs
# - Runs recon-all for each subject
# - Supports optional parallel execution
#
# Usage:
#   bash reconall_base.sh -s <subjects_dir> -l <subject_list> -j <n_jobs>
#
# Notes:
# - FreeSurfer must be installed and available in PATH
# - Optionally uses setup_env.sh if present (for module systems)

CONFIG_FILE="${CONFIG_FILE:-./config/config.sh}"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

set -euo pipefail

# Optional: load environment (e.g., modules on HPC systems)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/setup_env.sh" ]]; then
    source "$SCRIPT_DIR/setup_env.sh"
fi

# Default values (can be overridden with flags)
SUBJECTS_DIR="${SUBJECTS_DIR:-./freesurfer}"
SUBJECT_LIST="${SUBJECT_LIST:-./config/subjectlist.txt}"
N_JOBS="${N_JOBS:-1}"

# Basic usage function
usage() {
    echo "Usage: $0 [-s subjects_dir] [-l subject_list] [-j n_jobs]"
    exit 1
}

# Parse command-line arguments
while getopts "s:l:j:" opt; do
    case ${opt} in
        s ) SUBJECTS_DIR="$OPTARG" ;;
        l ) SUBJECT_LIST="$OPTARG" ;;
        j ) N_JOBS="$OPTARG" ;;
        * ) usage ;;
    esac
done

# Check subject list exists
if [[ ! -f "$SUBJECT_LIST" ]]; then
    echo "ERROR: subject list not found at $SUBJECT_LIST"
    exit 1
fi

# Create output directory if needed
mkdir -p "$SUBJECTS_DIR"

# Function to run recon-all for a single subject
run_recon() {
    local t1_file="$1"

    if [[ ! -f "$t1_file" ]]; then
        echo "ERROR: T1 file not found: $t1_file"
        return 1
    fi

    subject_id=$(basename "$t1_file" .nii.gz | sed 's/_T1w$//')

    echo "[$(date)] Starting recon-all for $subject_id"

    recon-all -i "$t1_file" -s "$subject_id" -all -sd "$SUBJECTS_DIR"

    if [[ $? -eq 0 ]]; then
        echo "[$(date)] Finished $subject_id"
    else
        echo "[$(date)] ERROR: recon-all failed for $subject_id"
        return 1
    fi
}

export SUBJECTS_DIR
export -f run_recon

# Run sequentially or in parallel
if [[ "$N_JOBS" -gt 1 ]]; then
    cat "$SUBJECT_LIST" | xargs -I {} -P "$N_JOBS" bash -c 'run_recon "$@"' _ {}
else
    while read -r t1_file; do
        run_recon "$t1_file"
    done < "$SUBJECT_LIST"
fi