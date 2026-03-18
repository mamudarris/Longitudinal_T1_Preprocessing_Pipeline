#!/usr/bin/env bash

# Author: Mohammed Mudarris
# Email: mamudarris@gmail.com
# Description:
# Runs FreeSurfer thalamic subnuclei segmentation on longitudinal base outputs.
#
# This script:
# - Reads subject IDs
# - Runs segment_subregions thalamus --long-base
#
# Usage:
#   bash thalamic_segmentation.sh -s <subjects_dir> -l <subject_list> -j <n_jobs>

set -euo pipefail

# Optional environment loading
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/Upload_Modules.sh" ]]; then
    source "$SCRIPT_DIR/Upload_Modules.sh"
fi

SUBJECTS_DIR="${SUBJECTS_DIR:-./freesurfer}"
SUBJECT_LIST="${SUBJECT_LIST:-./subjectlist_base.txt}"
N_JOBS="${N_JOBS:-1}"

usage() {
    echo "Usage: $0 [-s subjects_dir] [-l subject_list] [-j n_jobs]"
    exit 1
}

while getopts "s:l:j:" opt; do
    case ${opt} in
        s ) SUBJECTS_DIR="$OPTARG" ;;
        l ) SUBJECT_LIST="$OPTARG" ;;
        j ) N_JOBS="$OPTARG" ;;
        * ) usage ;;
    esac
done

if [[ ! -f "$SUBJECT_LIST" ]]; then
    echo "ERROR: subject list not found"
    exit 1
fi

run_thalamus() {
    local subject_id="$1"

    BASE="${subject_id}_base"

    if [[ ! -d "${SUBJECTS_DIR}/${BASE}" ]]; then
        echo "ERROR: ${BASE} not found, skipping"
        return 1
    fi

    echo "[$(date)] Starting thalamic segmentation for ${BASE}"

    segment_subregions thalamus --long-base "${BASE}"

    echo "[$(date)] Finished ${BASE}"
}

export SUBJECTS_DIR
export -f run_thalamus

if [[ "$N_JOBS" -gt 1 ]]; then
    cat "$SUBJECT_LIST" | xargs -I {} -P "$N_JOBS" bash -c 'run_thalamus "$@"' _ {}
else
    while read -r subject_id; do
        run_thalamus "$subject_id"
    done < "$SUBJECT_LIST"
fi
