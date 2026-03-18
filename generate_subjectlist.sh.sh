#!/usr/bin/env bash

set -euo pipefail

DATA_DIR="${1:-./data}"

mkdir -p config

# T1 files
find "$DATA_DIR" -name "*_T1w.nii.gz" | sort > config/subjectlist.txt

# Subject IDs
cat config/subjectlist.txt | \
    xargs -n1 basename | \
    sed 's/_ses-.*//' | \
    sort | uniq > config/subjectlist_base.txt

# Session IDs
cat config/subjectlist.txt | \
    xargs -n1 basename | \
    sed 's/_T1w.nii.gz//' > config/sessionlist.txt

echo "Lists generated in config/"