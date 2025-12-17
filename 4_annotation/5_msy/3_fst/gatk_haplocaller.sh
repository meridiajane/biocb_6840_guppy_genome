#!/bin/bash
#SBATCH --job-name=gatk_haplotypecaller
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 10
#SBATCH --mem=100G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../../Logs/%x_%j.out
#SBATCH -e ../../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Variables
## Input file
in=

## Index of reads from the input
idx=

## VCF output file
out=

## 'Ploidy', calculated as # Samples in Pool * Sample Ploidy
ploidy=

## Reference Sequence
ref=


#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Code Body
date

module load java
module load gatk

gatk --java-options "-Xmx4g" HaplotypeCaller \
    -R ${ref} \
    -I ${in} \
    -O ${out} \
    --read-index ${idx} \
    --sample-ploidy ${ploidy} 




date

