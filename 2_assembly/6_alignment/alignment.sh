#!/bin/bash
#SBATCH --job-name=alignment
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

# Path to minimap2
minimap=

# Path to cleaned reads
reads=

# Unpurged maternal assembly
mat=

# Unpurged paternal assembly
pat=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@

mkdir Renome.Mat.Align Renome.Pat.Align

# Link reads
ln -s ${reads} .

# Link assemblies
ln -s ${mat} ./Renome.Mat.Align/
ln -s ${pat} ./Renome.Pat.Align/

# Map the cleaned up reads to the purged contigs
${minimap} -t 30 -a -x map-hifi -o ./Renome.Mat.Align/renome.hap2.HiFi_to_unpurged.sam ${mat} ${reads}
${minimap} -t 30 -a -x map-hifi -o ./Renome.Pat.Align/renome.hap1.HiFi_to_unpurged.sam ${mat} ${reads}

# Convert to bam and sort
${samtools} view -@ 30 --bam ./Renome.Mat.Align/renome.hap2.HiFi_to_unpurged.sam | ${samtools} sort -@ 30 -o ./Renome.Mat.Align/renome.hap2.HiFi_to_unpurged.bam -
${samtools} view -@ 30 --bam ./Renome.Pat.Align/renome.hap1.HiFi_to_unpurged.sam | ${samtools} sort -@ 30 -o ./Renome.Pat.Align/renome.hap1.HiFi_to_unpurged.bam -

# Index the bam
${samtools} index -@ 30 ./Renome.Mat.Align/renome.hap2.HiFi_to_unpurged.bam
${samtools} index -@ 30 ./Renome.Pat.Align/renome.hap1.HiFi_to_unpurged.bam


