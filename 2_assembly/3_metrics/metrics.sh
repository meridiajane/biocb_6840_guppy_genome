#!/bin/bash
#SBATCH --job-name=linear_metrics
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 90
#SBATCH --mem=150G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../Logs/%x_%j.out
#SBATCH -e ../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Path to genometools
genometools=

# Path to paternal assembly
as_pat=

# Path to maternal assembly
as_mat=

# Path to BUSCO lineage database to use
lineage=

# Path to BUSCO singularity container
sing=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@

# Make initial assembly stats file of haplotigs

echo "Assembly Haplotigs" >> initialstats_pat.txt
${genometools} seqstat -contigs -genome 745000000 ${as_pat} >> initialstats_pat.txt
echo -e "\n" >> initialstats_pat.txt

echo "Assembly Primary Contigs" >> initialstats_mat.txt
${genometools} seqstat -contigs -genome 745000000 ${as_mat} >> initialstats_mat.txt
echo -e "\n" >> initialstats_mat.txt


# Run BUSCO on the original assembly

singularity run \
    --bind /local/storage/Projects/p_reticulata_assembly/ \
    --pwd  $(pwd) \
    ${sing} busco \
    -c 90 \
    -i ${as_pat} \
    -m genome \
    -l ${lineage} \
    --out Renome.Pat.prepurge

singularity run \
    --bind /local/storage/Projects/p_reticulata_assembly/ \
    --pwd  $(pwd) \
    ${sing} busco \
    -c 90 \
    -i ${as_mat} \
    -m genome \
    -l ${lineage} \
    --out Renome.Mat.prepurge
