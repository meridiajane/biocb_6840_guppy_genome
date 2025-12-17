#!/bin/bash
#SBATCH --job-name=manual_touchups_du
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 8
#SBATCH --mem=12G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../../../Logs/%x_%j.out
#SBATCH -e ../../../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Variables
## Paternal assembly
pat=

## Maternal assembly
mat=

## Oriented paternal assembly
init_pat=

## Oriented maternal assembly
init_mat=

## Output for reoriented mat assembly
out_mat=

## Output for reoriented pat assembly
out_pat=

## Minimap location
minimap=

## Seqtk 
seqtk=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Code Body
date

## Prepare env
mkdir work
cd work

## Fix the sequence order
#${seqtk} subseq ${pat} ../paternal_to_flip.txt > pat_toswitch.fa
#${seqtk} seq -r pat_toswitch.fa > pat_switched.fa
#grep ">" ${pat} | sed 's/>//' | grep -vf ../paternal_to_flip_grep.txt > pat_keeporiented.txt # Necessary to stop grep from patern matching out chr22 when filtering out chr2
#${seqtk} subseq ${pat} pat_keeporiented.txt > pat_oriented.fa
#cat pat_oriented.fa pat_switched.fa > pat_unordered.fa

#${seqtk} subseq ${mat} ../maternal_to_flip.txt > mat_toswitch.fa
#${seqtk} seq -r  mat_toswitch.fa > mat_switched.fa
#grep ">" ${mat} | sed 's/>//' | grep -vf ../maternal_to_flip_grep.txt > mat_keeporiented.txt # Necessary to stop grep from patern matching out chr22 when filtering out chr2
#${seqtk} subseq ${mat} mat_keeporiented.txt > mat_oriented.fa
#cat mat_oriented.fa mat_switched.fa > mat_unordered.fa


## Order and verify output
#for assembly in mat pat; do
#    samtools faidx ${assembly}_unordered.fa
#    grep ">" ${assembly}_unordered.fa | sort | sed 's/>//' > fasta_order.txt
#    samtools faidx ${assembly}_unordered.fa $(cat fasta_order.txt) > ${assembly}_ordered.fa
#done

#mv mat_ordered.fa ${out_mat}
#mv pat_ordered.fa ${out_pat}



${minimap} -x asm5 -t ${SLURM_JOB_CPUS_PER_NODE} ${out_mat} ${out_pat} > matpat_masked_ali.asm5.PAF

${minimap} -x asm5 -t ${SLURM_JOB_CPUS_PER_NODE} ${out_mat} ${init_mat} > matmat_maskedinit_ali.asm5.PAF
${minimap} -x asm5 -t ${SLURM_JOB_CPUS_PER_NODE} ${out_pat} ${init_pat} > patpat_maskedinit_ali.asm5.PAF

${minimap} -x asm5 -t ${SLURM_JOB_CPUS_PER_NODE} ${mat} ${init_mat} > matmat_oldmaskedinit_ali.asm5.PAF
${minimap} -x asm5 -t ${SLURM_JOB_CPUS_PER_NODE} ${pat} ${init_pat} > patpat_oldmaskedinit_ali.asm5.PAF

date
