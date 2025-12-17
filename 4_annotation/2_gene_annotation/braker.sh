#!/bin/bash
#SBATCH --job-name=braker
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 64
#SBATCH --mem=100G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../../Logs/%x_%j.out
#SBATCH -e ../../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Variables

## Path to BRAKER container
braker=

## Path to genome
genome=

## Dir containing short read RNA 
rna_dir=

## Bam of IsoSeq reads
isoseq_bam=

## Name to give fastq of IsoSeq reads
isoseq_fq=

## Braker working directory
work_dir=

## Short name of the assembly (e.g. mat or pat)
build=

## Orthodb protein database
prot_db=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Code Body

## Prepare environment 
module load minimap2

mkdir -p ${work_dir}/1_IsoSeq ${work_dir}/2_RNAseq ${work_dir}/3_TSERBA

## Step 1) Run Braker with IsoSeq reads
### Go to working directory
cd ${work_dir}/1_IsoSeq

### Make fastq from bam
samtools fastq -@ ${SLURM_JOB_CPUS_PER_NODE} -0 ${isoseq_fq} ${isoseq_bam}

### Add genome to directory
cp ${genome} Ret_${build}.genome.fa

### Add the protein database which was pulled from OrthoDB
cp ${prot_db} .

### Map IsoSeq reads to unmasked genome
minimap2 \
	-t ${SLURM_JOB_CPUS_PER_NODE} \
	-ax splice:hq \
	Ret_${build}.genome.fa \
	${work_dir}/1_IsoSeq/All_Ret_IsoSeq_Reads.fq \
	> Ret_${build}.iso_aligned.sam

### Convert to bam
samtools view \
	--threads ${SLURM_JOB_CPUS_PER_NODE} \
	-Sb Ret_${build}.iso_aligned.sam \
	> Ret_${build}.iso_aligned.bam

### Remove the sam file if the bam worked and has data
if [ -s "Ret_${build}.iso_aligned.bam" ]; then
   	echo "File Ret_${build}.iso_aligned.bam exists and has content."
   	# Remove the sam file
   	rm Ret_${build}.iso_aligned.sam
else
   	echo "File Ret_${build}.iso_aligned.bam either doesn't exist or is empty. Halting."
   	exit 1  # Exit the script with an error status
fi


### Add the Augustus_config_path from singularity and write it locally
singularity run --bind ${PWD} ${braker} cp -r /opt/Augustus/config ${PWD}

### Run braker-isoseq
singularity exec -B ${PWD}:${PWD} --env AUGUSTUS_CONFIG_PATH=$PWD/config ${braker} braker.pl \
		--species=P_reticulata_${build} \
		--genome=Ret_${build}.genome.fa \
		--prot_seq=Vertebrata.fa \
		--bam=Ret_${build}.iso_aligned.bam \
		--workingdir=braker3 \
		--threads=${SLURM_JOB_CPUS_PER_NODE} \
		--busco_lineage=actinopterygii_odb10

## Step 2) Run Braker with RNAseq reads

cd ${work_dir}/2_RNAseq

cat ${rna_dir}/*_1* >> rna_forward.fq
cat ${rna_dir}/*_2* >> rna_reverse.fq

### Add genome to directory
cp ${genome} Ret_$build.genome.fa

### Align the reads with hisat2 - it's expecting hisat's output formating
source /programs/HISAT2/hisat2.sh
hisat2-build Ret_$build.genome.fa Ret_$build.genome
hisat2 -p ${SLURM_JOB_CPUS_PER_NODE} -q -x Ret_${build}.genome -1 rna_forward.fq -2 rna_reverse.fq -S Ret_${build}.RNAseq.sam

### Convert sam to bam
samtools view -@ ${SLURM_JOB_CPUS_PER_NODE} -Sb Ret_${build}.RNAseq.sam > Ret_${build}.RNAseq.bam

### Remove the sam file if the bam worked and has data
if [ -s "Ret_${build}.RNAseq.bam" ]; then
   	echo "File Ret_${build}.RNAseq.bam exists and has content."
   	rm Ret_${build}.RNAseq.sam
else
   	echo "File Ret_${build}.RNAseq.bam either doesn't exist or is empty. Halting."
   	exit 1
fi

### Add the protein database pulled from OrthoDB
cp ${prot_db} .

### Add the Augustus_config_path from the singularity image and write locally
singularity run --bind ${PWD} ${braker} cp -r /opt/Augustus/config ${PWD}

### Run Braker with RNAseq Data
singularity exec -B ${PWD}:${PWD} --env AUGUSTUS_CONFIG_PATH=${PWD}/config ${braker} braker.pl \
		--species=P_reticulata_${build} \
	    --genome=Ret_${build}.genome.fa \
	    --prot_seq=Vertebrata.fa \
	    --bam=Ret_${build}.RNAseq.bam \
	    --workingdir=braker3 \
	    --threads=${SLURM_JOB_CPUS_PER_NODE} \
	    --busco_lineage=actinopterygii_odb10

## Step 3) Run TSERBA to combine RNAseq and IsoSeq gene models
cd ${work_dir}

# Run Tserba to combine gene sets from IsoSeq and RNAseq
singularity exec -B ${PWD}:${PWD} ${braker} tsebra.py \
      -g ${work_dir}/1_IsoSeq/braker3/braker.gtf,${work_dir}/2_RNAseq/braker3/braker.gtf \
      -e ${work_dir}/1_IsoSeq/braker3/hintsfile.gff,${work_dir}/2_RNAseq/braker3/hintsfile.gff \
      -o ${work_dir}/3_TSERBA/Ret_${build}.braker.combined.gtf

# Make fasta of protein and coding sequence
cd ${work_dir}/3_TSERBA

# Add genome to directory
cp ${genome} Ret_${build}.genome.fa

# Make fasta of protein and coding sequence
singularity exec -B ${PWD}:${PWD} ${braker} getAnnoFastaFromJoingenes.py \
	-g Ret_${build}.genome.fa -o Ret_${build} -f Ret_${build}.braker.combined.gtf

# Rename the gene names in the Tserba output so it can be used with Augustus script next
singularity exec -B ${PWD}:${PWD} ${braker} rename_gtf.py --gtf Ret_${build}.braker.combined.gtf --out Ret_${build}.braker.combined_renamed.gtf

# Generate a gff file
singularity exec -B ${PWD}:${PWD} ${braker} gtf2gff.pl <Ret_$build.braker.combined_renamed.gtf --out=Ret_${build}.braker.combined.gff
