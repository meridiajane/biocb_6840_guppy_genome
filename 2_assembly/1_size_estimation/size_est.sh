#!/bin/bash
#SBATCH --job-name=size_est
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 5
#SBATCH --mem=100G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../Logs/%x_%j.out
#SBATCH -e ../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Path to cleaned up hifi reads
reads=

# Path to meryl
meryl=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@

export R_LIBS=/programs/genomescrope-2.0
export PATH=/programs/genomescrope-2.0:$PATH

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@

ln -s ${reads} .

# Count kmers
${meryl} count k=21 memory=100 threads=$SLURM_CPUS_PER_TASK Cleaned.HiFiReads.fastq output out.meryl

# Create Histogram
${meryl} histogram out.meryl > out.reads.histo

# Run initial GenomeScope
genomescope.R -i out.reads.histo -o Cleaned_HiFi.GenomeScope_out -p 2 -k 21
