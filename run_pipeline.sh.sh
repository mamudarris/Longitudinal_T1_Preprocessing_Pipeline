#!/usr/bin/env bash

set -euo pipefail

# Load config
CONFIG_FILE="${CONFIG_FILE:-./config/config.sh}"
source "$CONFIG_FILE"

echo "Running cross-sectional..."
bash scripts/reconall_base.sh -s "$SUBJECTS_DIR" -l config/subjectlist.txt -j "$N_JOBS"

echo "Running base..."
bash scripts/reconall_base_template.sh -s "$SUBJECTS_DIR" -l config/subjectlist_base.txt -j "$N_JOBS"

echo "Running longitudinal..."
bash scripts/reconall_long.sh -s "$SUBJECTS_DIR" -l config/sessionlist.txt -j "$N_JOBS"

echo "Pipeline complete."