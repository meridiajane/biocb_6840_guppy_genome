#!/bin/bash
#SBATCH --job-name=sexed_kmers
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 24
#SBATCH --mem=128G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../../Logs/%x_%j.out
#SBATCH -e ../../Logs/%x_%j.err


#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@

# When running, comment out either the first half or the second half.
# Comment out the first half if you're working with the maternal/paternal
# read data. Comment out the second half if you're working with other 
# assemblies.

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Variables
## Path to meryl
meryl=

## Directory containing all male sequences in fasta format. Sequences
## should not be the ones from the assemblies being checked.
malseq=

## Directory containing all female sequences in fasta format. Sequences
## should not be the onest from the assemblies being checked.
femseq=

## Male prefix to add to out file
mfix=

## Female prefix to add to out file
ffix=

## kmer size
ksize=

## Minimum copy number to keep
copnum=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Code Body
date

## Generate female database
#${meryl} k=${ksize} count ${femseq}/* output ${ffix}_${ksize}.meryl

## Generate male database
#${meryl} k=${ksize} count ${malseq}/* output ${mfix}_${ksize}.meryl

## Only repeated kmers
#${meryl} k=${ksize} greater-than ${copnum} ${ffix}_${ksize}.meryl output ${ffix}_multicopy_${ksize}.meryl
#${meryl} k=${ksize} greater-than ${copnum} ${mfix}_${ksize}.meryl output ${mfix}_multicopy_${ksize}.meryl

## Identify unique kmers, use multicopy sex1 - any copy sex2 to make sure we don't let things slip just bc they're a rare snp in the other sex
${meryl} difference ${mfix}_multicopy_${ksize}.meryl ${ffix}_${ksize}.meryl output ${mfix}_multicopy_unq_${ksize}.meryl
${meryl} difference ${ffix}_multicopy_${ksize}.meryl ${mfix}_${ksize}.meryl output ${ffix}_multicopy_unq_${ksize}.meryl

## Output kmers as tsv
${meryl} print ${mfix}_multicopy_unq_${ksize}.meryl > ${mfix}_multicopy_unq_${ksize}.tsv
${meryl} print ${ffix}_multicopy_unq_${ksize}.meryl > ${ffix}_multicopy_unq_${ksize}.tsv

date
