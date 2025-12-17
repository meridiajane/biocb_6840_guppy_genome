#!/bin/bash
#SBATCH --job-name=linear_metrics
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 90
#SBATCH --mem=150G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../../../../../Logs/%x_%j.out
#SBATCH -e ../../../../../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Variables
## Path to genome tools
genometools=

## Path to kmerfreq
kmerfreq=

## Path to reads for species
reads=

## Paternal assembly
pat=

## Maternal assembly
mat=

## Busco lineage database
lineage=

## Busco singularity container
sing=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Code Body
## Make initial assembly stats file of haplotigs

#echo "Paternal Assembly Scaffold" > genomestats_pat.txt
#${genometools} seqstat -contigs -genome 719994475 ${pat} >> genomestats_pat.txt
#echo -e "\n" >> genomestats_pat.txt

#echo "Maternal Assembly Scaffold" > genomestats_mat.txt
#${genometools} seqstat -contigs -genome 719994475 ${mat} >> genomestats_mat.txt
#echo -e "\n" >> genomestats_mat.txt


# Run BUSCO on the original assembly

singularity run \
    --bind /local/storage/Projects/p_reticulata_assembly/ \
    --pwd  $(pwd) \
    ${sing} busco \
    -c 90 \
    -i ${pat} \
    -m genome \
    -l ${lineage} \
    --out Renome.Pat.postdu

#singularity run \
#    --bind /local/storage/Projects/p_reticulata_assembly/ \
#    --pwd  $(pwd) \
#    ${sing} busco \
#    -c 90 \
#    -i ${mat} \
#    -m genome \
#    -l ${lineage} \
#    --out Renome.Mat.postdu
