#!/bin/bash
#SBATCH --job-name=orthofinder
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 10
#SBATCH --mem=150G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../../../Logs/%x_%j.out
#SBATCH -e ../../../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Variables

## Conda env activate
conda=

## Name of conda env with orthofinder
env=

## Directory containing fastas
input=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Code Body
date

source ${conda}
conda activate ${env}
module load diamond

orthofinder \
    -f ${input} \
    -t ${SLURM_JOB_CPUS_PER_NODE} \
    -M msa \
    -A mafft \
    -T fasttree \
    -S diamond \
    -n renome_of

date
