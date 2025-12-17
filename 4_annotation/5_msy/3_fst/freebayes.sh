#!/bin/bash
#SBATCH --job-name=freebayes
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 2
#SBATCH --mem=1200G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../../Logs/%x_%j.out
#SBATCH -e ../../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Variables

## Directory to work/put outputs in
dir=

## Reference genome
genome=

## Reference genome index
gidx=

## Male and female BAMs
female_bam=
male_bam=

## Number of samples in pool
pool=

## Output VCF
out=

## Genome size
size=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Code Body
date

## Prep env
mkdir -p ${dir}
cd ${dir}
module load freebayes
source ~/miniconda3/bin/activate
conda activate vcflib

## Link in genome and bams for future reference
ln -s ${genome} .
ln -s ${gidx} .
ln -s ${male_bam} .
ln -s ${female_bam} .

## Calculate size of chunks to use for parallel compute
chunk=$((${size}/${SLURM_JOB_CPUS_PER_NODE}))

## Run FreeBayes in parallel
freebayes-parallel \
    <(fasta_generate_regions.py ${gidx} ${chunk}) \
    ${SLURM_JOB_CPUS_PER_NODE} \
    -f ${genome} \
    -p ${pool} \
    --pooled-discrete \
    --use-best-n-alleles 4 \
    ${male_bam} ${female_bam} > ${out}


## Run freebayes single threaded.
#freebayes ${SLURM_JOB_CPUS_PER_NODE} -f ${genome} -p ${pool} --pooled-discrete ${male_bam} ${female_bam} > ${out}

date

