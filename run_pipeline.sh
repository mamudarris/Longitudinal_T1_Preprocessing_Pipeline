#!/usr/bin/env bash

set -euo pipefail

# Load config
CONFIG_FILE="${CONFIG_FILE:-./config/config.sh}"
source "$CONFIG_FILE"

# Optional flags
RUN_THALAMUS=0

for arg in "$@"; do
    case $arg in
        --thalamus)
            RUN_THALAMUS=1
            ;;
    esac
done

echo "Running cross-sectional..."
bash scripts/reconall_base.sh -s "$SUBJECTS_DIR" -l config/subjectlist.txt -j "$N_JOBS"

echo "Running base..."
bash scripts/reconall_base_template.sh -s "$SUBJECTS_DIR" -l config/subjectlist_base.txt -j "$N_JOBS"

echo "Running longitudinal..."
bash scripts/reconall_long.sh -s "$SUBJECTS_DIR" -l config/sessionlist.txt -j "$N_JOBS"

# Optional step
if [[ "$RUN_THALAMUS" -eq 1 ]]; then
    echo "Running thalamic segmentation..."
    bash scripts/thalamic_segmentation.sh -s "$SUBJECTS_DIR" -l subjectlist_base.txt -j "$N_JOBS"
else
    echo "Skipping thalamic segmentation (use --thalamus to enable)"
fi

echo "Pipeline complete."
