#!/bin/bash  
#SBATCH --job-name=du_scaffolding  
#SBATCH --mail-user=mb2836@cornell.edu  
#SBATCH --mail-type=ALL  
#SBATCH -c 30  
#SBATCH --mem=100G  
#SBATCH --partition=regular  
#SBATCH --qos=regular  
#SBATCH -o ../../../../Logs/%x_%j.out  
#SBATCH -e ../../../../Logs/%x_%j.err  
  
#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@  
# Variables

## Path to virtual python environment with ragtag
venv=

## Path to minimap2
minimap=

## Path to ragtag
ragtag=

## Path to maternal assembly fasta
mat=

## Path to paternal assembly fasa
pat=

## Path to primary assembly
reference=
  
## Suffix for output directory
suffix=
#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@  
  
source ${venv}

ragtag.py scaffold -t ${SLURM_JOB_CPUS_PER_NODE} --aligner ${minimap} -rw -m 1000000 -g 10 -o ./mat_${suffix} ${reference} ${mat}

#ragtag.py scaffold -t ${SLURM_JOB_CPUS_PER_NODE} --aligner ${minimap} -rw -m 1000000 -g 10 -o ./pat_${suffix} ${reference} ${pat}
