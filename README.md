# Recon-all Longitudinal Pipeline

Bash-based pipeline for running FreeSurfer recon-all in a longitudinal framework using a BIDS directory structure.

## Requirements

- FreeSurfer (recon-all available in PATH)
- Optional: FSL
- Unix-based system (Linux/macOS)

## Repository Structure

```
.
├── scripts/
│   ├── reconall_base.sh
│   ├── reconall_base_template.sh
│   ├── reconall_long.sh
│   ├── setup_env.sh
│   └── generate_lists.sh
├── config/
│   ├── subjectlist.txt
│   ├── subjectlist_base.txt
│   └── sessionlist.txt
├── freesurfer/        # output directory (ignored by git)
├── logs/              # optional logs (ignored by git)
├── run_pipeline.sh
└── README.md
```

## Data Structure

Expected BIDS-like format:


data/
sub-XX/
ses-YY/
anat/
sub-XX_ses-YY_T1w.nii.gz


## Setup

Clone the repository:


git clone https://github.com/mamudarris/Longitudinal_T1_Preprocessing_Pipeline.git

cd Longitudinal_T1_Preprocessing_Pipeline


## Prepare Input Lists

Generate required input files automatically:


bash scripts/generate_lists.sh data/


This creates:

- `config/subjectlist.txt` → full T1 paths  
- `config/subjectlist_base.txt` → subject IDs  
- `config/sessionlist.txt` → session IDs  

## Run Pipeline

Run all steps sequentially:


bash run_pipeline.sh


Or run steps manually:


bash scripts/reconall_base.sh
bash scripts/reconall_base_template.sh
bash scripts/reconall_long.sh


## Notes

- Input files must follow `_T1w.nii.gz` naming
- Cross-sectional outputs must exist before running `-base`
- Base outputs must exist before running `-long`
- The script assumes two sessions per subject (modifiable)

## Citation

If you use this pipeline, please cite:

*Mudarris, M. A. (2026). A reproducible pipeline for longitudinal FreeSurfer recon-all processing using BIDS-formatted structure.*
