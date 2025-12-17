#!/bin/bash
#SBATCH --job-name=masking
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 64
#SBATCH --mem=96G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../../Logs/%x_%j.out
#SBATCH -e ../../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Variables

## Scaffolded Pat output
sca_pat=

## Scaffold Mat output
sca_mat=

## Date project was run
date=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@

# Prep workspace
mkdir mask_pat_${date} mask_mat_${date} sing_cont classifier

#singularity pull ./sing_cont/tetools.sif docker://dfam/tetools:latest

# Perform Paternal Modeling
cd mask_pat

#singularity exec \
#    --bind /local/storage/Projects/p_reticulata_assembly/ \
#    --pwd  $(pwd) \
#    ../sing_cont/tetools.sif BuildDatabase \
#    -name "pat_database" \
#    ${sca_pat}

#singularity exec \
#    --bind /local/storage/Projects/p_reticulata_assembly/ \
#    --pwd  $(pwd) \
#    ../sing_cont/tetools.sif RepeatModeler \
#    -threads ${SLURM_JOB_CPUS_PER_NODE} \
#    -database pat_database

# Perform Maternal Modeling
cd ../mask_mat

#singularity exec \
#    --bind /local/storage/Projects/p_reticulata_assembly/ \
#    --pwd  $(pwd) \
#    ../sing_cont/tetools.sif BuildDatabase \
#    -name "mat_database" \
#    ${sca_mat}

#singularity exec \
#    --bind /local/storage/Projects/p_reticulata_assembly/ \
#    --pwd  $(pwd) \
#    ../sing_cont/tetools.sif RepeatModeler \
#    -threads ${SLURM_JOB_CPUS_PER_NODE} \
#    -database mat_database

# Classify library
cd ../classifier

#cat ../mask_*/RM_*/consensi.fa > ./consensi.combined.fa

## Get repbase TE library
#cp /local/storage/Databases/RepBase29.06.embl/zebrafish_and_vertebrate_RepBase.lib .

## create your own copy of RepeatMasker database 
#singularity run \
#    --bind $PWD \
#    --pwd $PWD \
#    /local/storage/Projects/p_reticulata_assembly/5_annotation/1_mask/sing_cont/tetools.sif \
#    cp -r /opt/RepeatMasker ./

## delete the built in database
#pwd
#rm RepeatMasker/Libraries/RepeatMasker.*

## replace "myDatabase.lib" in the next command with the .lib file you produced from previous step 
cd RepeatMasker/Libraries/
#pwd
#cp /local/storage/Projects/p_reticulata_assembly/5_annotation/1_mask/classifier/zebrafish_and_vertebrate_RepBase.lib RepeatMasker.lib
#makeblastdb -dbtype nucl -in RepeatMasker.lib

# when you run RepeatClassifier, copy over the RepeatMasker directory to same place as the consensi.fa file. 
# specify your RepeatMasker directory which include the custom db "-repeatmasker_dir ./RepeatMasker"
cd ../../
#singularity run --bind $PWD \
#    --pwd $PWD \
#    /local/storage/Projects/p_reticulata_assembly/5_annotation/1_mask/sing_cont/tetools.sif RepeatClassifier \
#    -consensi consensi.combined.fa \
#    -repeatmasker_dir ./RepeatMasker \
#    > consensi.combined.fa.classified


# Perform Masking
cd ../
singularity exec \
    --bind /local/storage/Projects/p_reticulata_assembly/ \
    --pwd  $(pwd) \
    /local/storage/Projects/p_reticulata_assembly/5_annotation/1_mask/sing_cont/tetools.sif RepeatMasker \
    -dir paternal_masked \
    -lib /local/storage/Projects/p_reticulata_assembly/5_annotation/1_mask/classifier/consensi.combined.fa.classified \
    -gff -a -noisy \
    -xsmall ${sca_pat}

singularity exec \
    --bind /local/storage/Projects/p_reticulata_assembly/ \
    --pwd  $(pwd) \
    /local/storage/Projects/p_reticulata_assembly/5_annotation/1_mask/sing_cont/tetools.sif RepeatMasker \
    -dir maternal_masked \
    -lib /local/storage/Projects/p_reticulata_assembly/5_annotation/1_mask/classifier/consensi.combined.fa.classified \
    -gff -a -noisy \
    -xsmall ${sca_mat}
