#!/bin/bash
#SBATCH --job-name=illumina_map
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 10
#SBATCH --mem=50G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../../Logs/%x_%j.out
#SBATCH -e ../../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Variables

## Female illumina reads
fem_ill1=
fem_ill2=

## Male illumina reads
mal_ill1=
mal_ill2=

## Genome with autosomes plus the x and the y
genome=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Code Body
date

## Prep environment
module load bwa-mem2
mkdir ill_map
cd ill_map

## Prep data
bwa-mem2 index ${genome}

## Map female reads to autosome + xy

bwa-mem2 mem -R '@RG\tID:HT1008\tSM:2\tLB:female_pool\tPL:NovaSeqX' -t ${SLURM_JOB_CPUS_PER_NODE} ${genome} ${fem_ill1} ${fem_ill2} > female_ill_autxy_aln.sam

samtools view -@ ${SLURM_JOB_CPUS_PER_NODE} female_ill_autxy_aln.sam -o female_ill_autxy_aln.bam
samtools sort -@ ${SLURM_JOB_CPUS_PER_NODE} female_ill_autxy_aln.bam -o female_ill_autxy_aln.bam.sorted
samtools index -@ ${SLURM_JOB_CPUS_PER_NODE} female_ill_autxy_aln.bam.sorted -o female_ill_autxy_aln.bam.sorted.bai
    
#bedtools genomecov -d -ibam female_ill_autxy_aln.bam.sorted > female_ill_autxy_aln.tsv

## Map male reads to autosome + xy

bwa-mem2 mem -R '@RG\tID:HT1008\tSM:1\tLB:male_pool\tPL:NovaSeqX' -t ${SLURM_JOB_CPUS_PER_NODE} ${genome} ${mal_ill1} ${mal_ill2} > male_ill_autxy_aln.sam

samtools view -@ ${SLURM_JOB_CPUS_PER_NODE} male_ill_autxy_aln.sam -o male_ill_autxy_aln.bam
samtools sort -@ ${SLURM_JOB_CPUS_PER_NODE} male_ill_autxy_aln.bam -o male_ill_autxy_aln.bam.sorted
samtools index -@ ${SLURM_JOB_CPUS_PER_NODE} male_ill_autxy_aln.bam.sorted -o male_ill_autxy_aln.bam.sorted.bai

bedtools genomecov -d -ibam male_ill_autxy_aln.bam.sorted > male_ill_autxy_aln.tsv

date

