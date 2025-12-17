#!/bin/bash
#SBATCH --job-name=read_metrics
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 4
#SBATCH --mem=24G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../Logs/%x_%j.out
#SBATCH -e ../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@

## Path to genometools
genometools=

## Path to reads
reads=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@

# Make initial assembly stats file of haplotigs

echo "Initial reads, No adaptors" >> readstats.txt
${genometools} seqstat -contigs -genome 745000000 ${reads} >> readstats.txt
echo -e "\n" >> readstats.txt

