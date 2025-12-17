#!/bin/bash
#SBATCH --job-name=remove_circs
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 30
#SBATCH --mem=100G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../Logs/%x_%j.out
#SBATCH -e ../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Raw paternal assembly
raw_pat=

# Raw maternal assembly
raw_mat=

# Path to samtools
samtools=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@

### For the paternal assembly

# Generate a list of the circular contigs
grep ">" ${raw_pat} | grep "c" | awk -F ">" '{print $2}' > circular_contigs_pat.txt

# Generater index of the fasta file to get list of all sequences
${samtools} faidx ${raw_pat}

# Subtract the circular contigs from the list of all contigs to use in next step
remove_ids=($(awk '{print $1}' ${raw_pat}.fai | grep -v -f circular_contigs_pat.txt))

# Keep only the linear contigs
${samtools} faidx -o renome.asm.dip.hap1.p_ctg.gfa.fasta ${raw_pat} "${remove_ids[@]}"


### For the maternal assembly

# Generate a list of the circular contigs
grep ">" ${raw_mat} | grep "c" | awk -F ">" '{print $2}' > circular_contigs_mat.txt

# Generater index of the fasta file to get list of all sequences
${samtools} faidx ${raw_mat}

# Subtract the circular contigs from the list of all contigs to use in next step
remove_ids=($(awk '{print $1}' ${raw_mat}.fai | grep -v -f circular_contigs_mat.txt))

# Keep only the linear contigs
${samtools} faidx -o renome.asm.dip.hap2.p_ctg.gfa.fasta ${raw_mat} "${remove_ids[@]}"

