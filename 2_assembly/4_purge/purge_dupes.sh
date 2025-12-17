#!/bin/bash
#SBATCH --job-name=purge_dupes
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 90
#SBATCH --mem=150G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../Logs/%x_%j.out
#SBATCH -e ../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Path to genome tools
genometools=

# Path to paternal assembly
as_pat=

# Path to maternal assembly
as_mat=

# Path to cleaned reads
reads=

# Path to BUSCO lineage database
lineage=

# Path to BUSCO singularity container
sing=

# Path to minimap2
minimap=

# Path to purge dupes (program)
purge_dupes=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@

# Round 1 - Purge Duplicates from the Pat assembly
mkdir purge_pat
cd purge_pat

# Map the cleaned up reads to the filtered builds
${minimap} -t 90 -x map-hifi ${as_pat} ${reads} | gzip -c - > renome.hap1.mapped.paf.gz

# Make PB.base.cov and PB.stat files with pbcstat script
${purge_dupes}bin/pbcstat renome.hap1.mapped.paf.gz
${purge_dupes}bin/calcuts PB.stat > cutoffs 2>calcults.log

# Split assembly and run a self-self alignment
${purge_dupes}bin/split_fa ${as_pat} > renome.hap1.fasta.split
${minimap} -xasm5 -t 90 -DP renome.hap1.fasta.split renome.hap1.fasta.split | gzip -c - > renome.hap1.fasta.split.self.paf.gz

# Purge haplotigs and overlaps
${purge_dupes}bin/purge_dups -2 -T cutoffs -c PB.base.cov renome.hap1.fasta.split.self.paf.gz > dups.renome.hap1.bed 2> purge_dups.renome.hap1.log

# Get purged primary and haplotig sequences from assembly
${purge_dupes}bin/get_seqs -e dups.renome.hap1.bed ${as_pat}

cp purged.fa ../renome.hap1.primary.purged.fa

# Plot the coverage cutoffs that purge_dups used, in plots:
# Below red line is considered 'low coverage', and classified as 'Junk' in the bed file.
# Dark green is transition between haploid and diploid coverage.
# Teal green is considered 'high coverage', and contigs above are classified as repeats
${purge_dupes}scripts/hist_plot.py -c cutoffs PB.stat renome.hap1.purge_dups.cov.png

# Download and view the .png file to verify it made transition calls properly.

# Run BUSCO on the purged assembly after one round of purging

singularity run \
    --bind /local/storage/Projects/p_reticulata_assembly/ \
    --pwd  $(pwd) \
    ${sing} busco \
    -c 90 \
    -i ../renome.hap1.primary.purged.fa \
    -m genome \
    -l ${lineage} \
    --out Renome.Pat.purge

cd ..


# Round 2 - Purge Duplicates from the Mat assembly
mkdir purge_mat
cd purge_mat

# Map the cleaned up reads to the filtered builds
${minimap} -t 90 -x map-hifi ${as_mat} ${reads} | gzip -c - > renome.hap2.mapped.paf.gz

# Make PB.base.cov and PB.stat files with pbcstat script
${purge_dupes}bin/pbcstat renome.hap2.mapped.paf.gz
${purge_dupes}bin/calcuts PB.stat > cutoffs 2>calcults.log

# Split assembly and run a self-self alignment
${purge_dupes}bin/split_fa ${as_mat} > renome.hap2.fasta.split
${minimap} -xasm5 -t 90 -DP renome.hap2.fasta.split renome.hap2.fasta.split | gzip -c - > renome.hap2.fasta.split.self.paf.gz

# Purge haplotigs and overlaps
${purge_dupes}bin/purge_dups -2 -T cutoffs -c PB.base.cov renome.hap2.fasta.split.self.paf.gz > dups.renome.hap2.bed 2> purge_dups.renome.hap2.log

# Get purged primary and haplotig sequences from assembly
${purge_dupes}bin/get_seqs -e dups.renome.hap2.bed ${as_mat}

cp purged.fa ../renome.hap2.primary.purged.fa

# Plot the coverage cutoffs that purge_dups used, in plots:
# Below red line is considered 'low coverage', and classified as 'Junk' in the bed file.
# Dark green is transition between haploid and diploid coverage.
# Teal green is considered 'high coverage', and contigs above are classified as repeats
${purge_dupes}scripts/hist_plot.py -c cutoffs PB.stat renome.hap2.purge_dups.cov.png

# Download and view the .png file to verify it made transition calls properly.

# Run BUSCO on the purged assembly after one round of purging

singularity run \
    --bind /local/storage/Projects/p_reticulata_assembly/ \
    --pwd  $(pwd) \
    ${sing} busco \
    -c 90 \
    -i ../renome.hap2.primary.purged.fa \
    -m genome \
    -l ${lineage} \
    --out Renome.Mat.purge

cd ..
