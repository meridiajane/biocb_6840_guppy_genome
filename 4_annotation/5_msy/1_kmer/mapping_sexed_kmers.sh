#!/bin/bash
#SBATCH --job-name=sexed_kmer_map
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 20
#SBATCH --mem=75G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../../Logs/%x_%j.out
#SBATCH -e ../../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Variables

## Paternal Scaffolds
pat=

## Maternal Scaffolds
mat=

## Y chr scaffold
y=

## X chr scaffold
x=

## kmers female
fmer=

## kmers male
mmer=

## kmer length
klen=

## Output dir
output=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Code Block
## Prepare environment
mkdir ${output}

## Prepare reference
cd ${output}

## Save variables:
printf "pat\t"${pat}"\nmat\t"${mat}"\ny\t"${y}"\nx\t"${x}"\nfmer\t"${fmer}"\nmmer\t"${mmer}"\nklen\t"${klen}"\noutput\t"${output} > variables_used.txt

## Kmermap for a paternal autosome and X set
cp ${pat} pat_x.fa
seqkit grep -p ${x} ${mat} >> pat_x.fa
bowtie2-build pat_x.fa pat_x

## Generate fmer depth
bowtie2 --no-1mm-upfront -N 0 -L 20 -fap ${SLURM_JOB_CPUS_PER_NODE} -x pat_x -U ${fmer} -S pat_x_fmer_aln.sam
samtools view -@ ${SLURM_JOB_CPUS_PER_NODE} pat_x_fmer_aln.sam -o pat_x_fmer_aln.bam
samtools sort -@ ${SLURM_JOB_CPUS_PER_NODE} pat_x_fmer_aln.bam -o pat_x_fmer_aln.bam.sorted
samtools index -@ ${SLURM_JOB_CPUS_PER_NODE} pat_x_fmer_aln.bam.sorted -o pat_x_fmer_aln.bam.sorted.bai

bedtools genomecov -d -ibam pat_x_fmer_aln.bam.sorted > pat_x_fmer_aln_perbase_cov.tsv

## Generate mmer depth
bowtie2 --no-1mm-upfront -N 0 -L 20 -fap ${SLURM_JOB_CPUS_PER_NODE} -x pat_x -U ${mmer} -S pat_x_mmer_aln.sam
samtools view -@ ${SLURM_JOB_CPUS_PER_NODE} pat_x_mmer_aln.sam -o pat_x_mmer_aln.bam
samtools sort -@ ${SLURM_JOB_CPUS_PER_NODE} pat_x_mmer_aln.bam -o pat_x_mmer_aln.bam.sorted
samtools index -@ ${SLURM_JOB_CPUS_PER_NODE} pat_x_mmer_aln.bam.sorted -o pat_x_mmer_aln.bam.sorted.bai

bedtools genomecov -d -ibam pat_x_mmer_aln.bam.sorted > pat_x_mmer_aln_perbase_cov.tsv
