#!/bin/bash
#SBATCH --job-name=purge_metrics
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 30
#SBATCH --mem=100G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../Logs/%x_%j.out
#SBATCH -e ../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Path to genome tools
genometools=

# Purged paternal assembly
pur_pat=

# Purged maternal assembly
pur_mat=

# BUSCO summary of post purge paternal assembly
bus_pat=

# BUSCO summary of post purge maternal assembly
bus_mat=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@

# Make initial assembly stats file of haplotigs

echo "Assembly Haplotigs" >> purgestats_pat.txt
${genometools} seqstat -contigs -genome 745000000 ${pur_pat} >> purgestats_pat.txt
echo -e "\n" >> purgestats_pat.txt

echo "Assembly Primary Contigs" >> purgestats_mat.txt
${genometools} seqstat -contigs -genome 745000000 ${pur_mat} >> purgestats_mat.txt
echo -e "\n" >> purgestats_mat.txt


# Link BUSCO results from purge_duplicates

ln -s ${bus_pat} .
ln -s ${bus_mat} .
