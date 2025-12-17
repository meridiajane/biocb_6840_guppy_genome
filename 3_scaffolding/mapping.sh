#!/bin/bash
#SBATCH --job-name=mapping_assessment
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

## Path to Minimap 
minimap=

## Path to percent_scaf_to_chr.py 
per=

## Paternal Scaffolds
pat_sca=

## Paternal contigs
pat_con=

## Maternal Scaffolds
mat_sca=

## Maternal contigs
mat_con=

## Reference Genome
#ref=(Du as reference)
ref=(Kunster as reference)

## Python venv with pandas
venv=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Code Block
## Prepare environment
mkdir mat_aln pat_aln mat_aln/mat_con mat_aln/mat_sca pat_aln/pat_con pat_aln/pat_sca

## Assembly to assembly/ref alignment
${minimap} -x asm5 ${ref} ${mat_con} > ./mat_aln/mat_con/mat_con_aln.PAF
${minimap} -x asm5 ${ref} ${mat_sca} > ./mat_aln/mat_sca/mat_sca_aln.PAF
${minimap} -x asm5 ${ref} ${pat_con} > ./pat_aln/pat_con/pat_con_aln.PAF
${minimap} -x asm5 ${ref} ${pat_sca} > ./pat_aln/pat_sca/pat_sca_aln.PAF

## Calculate percentage alignment to the chromosome
cd ./mat_aln/mat_con
cut -f1-17 mat_con_aln.PAF | ${venv} ${per}
cd ../mat_sca
cut -f1-17 mat_sca_aln.PAF | ${venv} ${per}
cd ../../pat_aln/pat_con
cut -f1-17 pat_con_aln.PAF | ${venv} ${per}
cd ../pat_sca
cut -f1-17 pat_sca_aln.PAF | ${venv} ${per}
