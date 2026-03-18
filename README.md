# Recon-all Longitudinal Pipeline

Bash-based pipeline for running FreeSurfer recon-all in a longitudinal framework using a BIDS directory structure.

## Requirements

- FreeSurfer (recon-all available in PATH)
- Optional: FSL
- Unix-based system (Linux/macOS)

## Repository Structure

```
.
├── step1_recon-all-cross.sh # cross-sectional recon-all
├── step2_recon-all-base-template.sh # base creation
├── step3_recon-all-long.sh # longitudinal processing
├── run_pipeline.sh # runs full pipeline sequentially
├── generate_subjectlist.sh # generates input lists
├── Upload_Modules.sh # optional environment setup
├── config.sh # configuration file
├── subjectlist.txt # example input list
├── scripts/
│ └── slurm/
│ └── run_pipeline.slurm # SLURM wrapper
├── README.md
├── LICENSE
└── .gitignore
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

## Optional Steps

### Thalamic segmentation

Run the full pipeline including thalamic subnuclei segmentation:
bash run_pipeline.sh --thalamus


This step runs:

segment_subregions thalamus --long-base


and requires completed longitudinal outputs.

## Notes

- Input files must follow `_T1w.nii.gz` naming
- Cross-sectional outputs must exist before running `-base`
- Base outputs must exist before running `-long`
- The script assumes two sessions per subject (modifiable)

## Citation

If you use this pipeline, please cite:

*Mudarris, M. A. (2026). A reproducible pipeline for longitudinal FreeSurfer recon-all processing using BIDS-formatted structure.*
