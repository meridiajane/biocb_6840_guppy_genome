#!/bin/bash
#SBATCH --job-name=du_scaffold_cleanup
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 8
#SBATCH --mem=20G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../../../../Logs/%x_%j.out
#SBATCH -e ../../../../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Variables

## Genome to name and order
genome=

## Reference genome
ref=

## Location of Percent Scaf to Chr
percent=

## Location of venv for Percent Scaf to Chr
venv=

## Are you working on "mat" or "pat"
assembly=

## Location of minimap2
minimap=

## Location of seqtk
seqtk=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Code Body
date

source ${venv}

mkdir -p $(pwd)/${assembly}_naming/
cd $(pwd)/${assembly}_naming/

## Identify chromosomes
### Map scaffolds to the reference
${minimap} -x asm5 -t ${SLURM_JOB_CPUS_PER_NODE} ${ref} ${genome} > scaf2ref.asm5.PAF

### Identify best mapping for each scaffold
cut -f1-17 scaf2ref.asm5.PAF | python3 ${percent}

### Make file of scaffolds that are the chromosomes
awk '($3 > 10000000)' bestmatch.tsv | tail -n +2 | sort -k2,2 | awk '{print $1}' > chr_scafs.txt

## Orient scaffolds
### Make list of scaffolds to reverse complement
for i in {31..53}
do
	grep -f chr_scafs.txt scaf2ref.asm5.PAF | grep "NC_0243${i}" | sort -k10,10n | tail -1 | awk '($5 == "-"){print $1}' >> to_reverse.txt
done

### Make list of scaffolds to leave orientation
grep ">" ${genome} | sed 's/>//' | grep -vf to_reverse.txt - > keep_oriented.txt

### Make fasta of just scaffolds to leave orientation
${seqtk} subseq ${genome} keep_oriented.txt > left_oriented.fa

### Make fasta of scaffolds reverse complement
${seqtk} subseq ${genome} to_reverse.txt > to_switch.fa

### Reverse complement
${seqtk} seq -r to_switch.fa > fixed_orientation.fa

### Bring back together to one fasta
cat left_oriented.fa fixed_orientation.fa > proper_orientation.fa

chr=1
cp proper_orientation.fa ${assembly}.oriented.chrNamed.fa

for line in $(cat chr_scafs.txt); do
	sed -i "s/${line}$/${assembly}_reticulata_chr${chr}/" ${assembly}.oriented.chrNamed.fa
    (( chr+=1 ))
done

## Order and verify output
### Generate an index
samtools faidx ${assembly}.oriented.chrNamed.fa

### Reorder the chromosomes in the fasta file
grep ">" ${assembly}.oriented.chrNamed.fa | sort | sed 's/>//' > fasta_order.txt

### Reorder the chromosomes in the fasta file
samtools faidx ${assembly}.oriented.chrNamed.fa $(cat fasta_order.txt) > ${assembly}.ordered.oriented.chrNamed.fa

### Check mapping to female
mkdir check_orient_to_ref
cd check_orient_to_ref

${minimap} -x asm5 -t ${SLURM_JOB_CPUS_PER_NODE} ${ref} ../${assembly}.ordered.oriented.chrNamed.fa > ${assembly}.mapped.to_ref.asm5.PAF
	
### Identify best mapping for each scaffold
cut -f1-17 ${assembly}.mapped.to_ref.asm5.PAF | python3 ${percent}

date
