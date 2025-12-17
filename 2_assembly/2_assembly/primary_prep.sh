#!/bin/bash
#SBATCH --job-name=primary_remove_circs
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 30
#SBATCH --mem=100G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../Logs/%x_%j.out
#SBATCH -e ../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Path to samtools
samtools=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@

# Convert gfa to fasta
awk '/^S/{print ">"$2;print $3}' renome.asm.p_ctg.gfa > raw.renome.asm.p_ctg.gfa.fasta

# Generate a list of the circular contigs
grep ">" raw.renome.asm.p_ctg.gfa.fasta | grep "c" | awk -F ">" '{print $2}' > circular_contigs_primary.txt

# Generater index of the fasta file to get list of all sequences
${samtools} faidx raw.renome.asm.p_ctg.gfa.fasta

# Subtract the circular contigs from the list of all contigs to use in next step
remove_ids=($(awk '{print $1}' raw.renome.asm.p_ctg.gfa.fasta.fai | grep -v -f circular_contigs_primary.txt))

# Keep only the linear contigs
${samtools} faidx -o renome.asm.p_ctg.gfa.fasta raw.renome.asm.p_ctg.gfa.fasta "${remove_ids[@]}"

