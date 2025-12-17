#!/bin/bash
#SBATCH --job-name=hifiasm
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 30
#SBATCH --mem=100G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../Logs/%x_%j.out
#SBATCH -e ../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Path to hifiasm
hifiasm=

# Path to yak
yak=

# Path to offspring long reads
kid_reads=

# Path to maternal short reads
mom_reads=

# Path to paternal short reads
dad_reads=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@

# Finding kmers for trio binning
${yak} count -k31 -b37 -t90 -o pat.yak ${dad_reads}
${yak} count -k31 -b37 -t90 -o mat.yak ${mom_reads}

# Generating both primary/alternate assemblies and trio binning assemblies
${hifiasm} -o renome.asm --primary -t 32 ${kid_reads}
${hifiasm} -o renome.asm -t 90 -1 pat.yak -2 mat.yak /dev/null

# Phase switch error rate evaluation
echo "Maternal"
awk '/^S/{print ">"$2;print $3}' renome.asm.dip.hap2.p_ctg.gfa > raw.renome.asm.dip.hap2.p_ctg.gfa.fasta 
${yak} trioeval -t90 pat.yak mat.yak raw.renome.asm.dip.hap2.p_ctg.gfa.fasta
echo "Paternal"
awk '/^S/{print ">"$2;print $3}' renome.asm.dip.hap1.p_ctg.gfa > raw.renome.asm.dip.hap1.p_ctg.gfa.fasta
${yak} trioeval -t90 pat.yak mat.yak raw.renome.asm.dip.hap1.p_ctg.gfa.fasta
