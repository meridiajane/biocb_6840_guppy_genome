#!/bin/bash
#SBATCH --job-name=hifiasm_contam
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 90
#SBATCH --mem=1000G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../Logs/%x_%j.out
#SBATCH -e ../Logs/%x_%j.err


# Path to adaptor filtered reads
input_seq=

# Path to hifiasm
hifiasm=

# Run hifiasm
${hifiasm} -t 90 -o ./Initial_Build.asm ${input_seq}

# Make fasta files from the gfa file
awk '/^S/{print ">"$2;print $3}' Initial_Build.asm.bp.p_ctg.gfa > Initial_Build.asm.bp.p_ctg.gfa.fasta 


