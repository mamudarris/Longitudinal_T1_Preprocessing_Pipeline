#!/usr/bin/env bash

# Author: Mohammed Mudarris
# Email: mamudarris@gmail.com
# Last update: 20260318
# Description:
# Runs FreeSurfer recon-all -long for longitudinal processing.
# Assumes that both cross-sectional and -base processing are completed.
#
# This script:
# - Reads a list of session IDs (e.g., sub-01_ses-01)
# - Extracts subject ID to identify the corresponding base
# - Runs recon-all -long for each session
#
# Usage:
#   bash reconall_long.sh -s <subjects_dir> -l <session_list> -j <n_jobs>
#
# Notes:
# - Requires existing cross-sectional and base outputs
# - Session list should contain entries like: sub-XX_ses-YY

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
SESSION_LIST="${SESSION_LIST:-./config/sessionlist.txt}"
N_JOBS="${N_JOBS:-1}"

usage() {
    echo "Usage: $0 [-s subjects_dir] [-l session_list] [-j n_jobs]"
    exit 1
}

# Parse arguments
while getopts "s:l:j:" opt; do
    case ${opt} in
        s ) SUBJECTS_DIR="$OPTARG" ;;
        l ) SESSION_LIST="$OPTARG" ;;
        j ) N_JOBS="$OPTARG" ;;
        * ) usage ;;
    esac
done

# Check session list exists
if [[ ! -f "$SESSION_LIST" ]]; then
    echo "ERROR: session list not found at $SESSION_LIST"
    exit 1
fi

mkdir -p "$SUBJECTS_DIR"

# Function to run longitudinal processing for one session
run_long() {
    local session_id="$1"

    if [[ -z "$session_id" ]]; then
        echo "ERROR: empty session ID"
        return 1
    fi

    # Extract subject ID (e.g., sub-01 from sub-01_ses-01)
    subject_base=$(echo "$session_id" | cut -d'_' -f1)
    BASE="${subject_base}_base"

    echo "[$(date)] Starting recon-all -long for $session_id (base: $BASE)"

    recon-all -long "$session_id" "$BASE" -all -sd "$SUBJECTS_DIR"

    if [[ $? -eq 0 ]]; then
        echo "[$(date)] Finished -long for $session_id"
    else
        echo "[$(date)] ERROR: recon-all -long failed for $session_id"
        return 1
    fi
}

export SUBJECTS_DIR
export -f run_long

# Run sequentially or in parallel
if [[ "$N_JOBS" -gt 1 ]]; then
    cat "$SESSION_LIST" | xargs -I {} -P "$N_JOBS" bash -c 'run_long "$@"' _ {}
else
    while read -r session_id; do
        run_long "$session_id"
    done < "$SESSION_LIST"
fi