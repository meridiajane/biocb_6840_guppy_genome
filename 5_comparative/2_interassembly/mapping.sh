#!/bin/bash
#SBATCH --job-name=matpat_du_map
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 30
#SBATCH --mem=100G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../../Logs/%x_%j.out
#SBATCH -e ../../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Variables

## Maternal Assembly
mat=

## Paternal Assembly
pat=

## Du Assembly
du=

## Reference Assembly
ref=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Code Block
date

## Prepare environment
mkdir du_mapping ./du_mapping/pat ./du_mapping/mat
module load minimap2

## Mat 2 refs alignment
cd du_mapping/mat
minimap2 -x asm5 ${du} ${mat} > mat_du_aln.PAF
minimap2 -x asm5 ${ref} ${mat} > mat_ref_aln.PAF


## Pat 2 refs alignment
cd ../pat
minimap2 -x asm5 ${du} ${pat} > pat_du_aln.PAF
minimap2 -x asm5 ${ref} ${pat} > pat_ref_aln.PAF

date
