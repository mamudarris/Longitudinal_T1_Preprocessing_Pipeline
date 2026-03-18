#!/usr/bin/env bash

# Author: Mohammed Mudarris
# Email: mamudarris@gmail.com
# Last Update: 20260318
# Description:
# Runs FreeSurfer recon-all -base for longitudinal processing.
# Assumes that cross-sectional recon-all has already been completed.
#
# This script:
# - Reads a list of subject IDs (e.g., sub-01)
# - Constructs timepoints using a BIDS-like format (ses-01, ses-02)
# - Runs recon-all -base for each subject
#
# Usage:
#   bash reconall_base_template.sh -s <subjects_dir> -l <subject_list> -j <n_jobs>
#
# Notes:
# - Cross-sectional runs must exist (sub-XX_ses-YY folders)
# - Timepoints are currently hardcoded (ses-01, ses-02)
# - Modify if more sessions are present

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

# Default values
SUBJECTS_DIR="${SUBJECTS_DIR:-./freesurfer}"
SUBJECT_LIST="${SUBJECT_LIST:-./config/subjectlist_base.txt}"
N_JOBS="${N_JOBS:-1}"

usage() {
    echo "Usage: $0 [-s subjects_dir] [-l subject_list] [-j n_jobs]"
    exit 1
}

# Parse arguments
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

mkdir -p "$SUBJECTS_DIR"

# Function to run base processing for one subject
run_base() {
    local subject_id="$1"

    if [[ -z "$subject_id" ]]; then
        echo "ERROR: empty subject ID"
        return 1
    fi

    BASE="${subject_id}_base"
    TP1="${subject_id}_ses-01"
    TP2="${subject_id}_ses-02"

    echo "[$(date)] Starting recon-all -base for $subject_id"

    recon-all -base "$BASE" -tp "$TP1" -tp "$TP2" -all -sd "$SUBJECTS_DIR"

    if [[ $? -eq 0 ]]; then
        echo "[$(date)] Finished -base for $subject_id"
    else
        echo "[$(date)] ERROR: recon-all -base failed for $subject_id"
        return 1
    fi
}

export SUBJECTS_DIR
export -f run_base

# Run sequentially or in parallel
if [[ "$N_JOBS" -gt 1 ]]; then
    cat "$SUBJECT_LIST" | xargs -I {} -P "$N_JOBS" bash -c 'run_base "$@"' _ {}
else
    while read -r subject_id; do
        run_base "$subject_id"
    done < "$SUBJECT_LIST"
fi