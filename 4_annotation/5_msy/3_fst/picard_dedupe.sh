#!/bin/bash
#SBATCH --job-name=picard_dedupe
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 10
#SBATCH --mem=50G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../../Logs/%x_%j.out
#SBATCH -e ../../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Variables
## Input file
in=

## Picard processing output directory
out=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Code Body
date

module load java
module load picard

mkdir ${out}

picard MarkDuplicates INPUT=${in} OUTPUT=${out}/$(basename ${in}).dedupe METRICS_FILE=${out}/$(basename ${in}).dedupe.metrics.txt





date

