#!/bin/bash
#SBATCH --job-name=bbduk
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 24
#SBATCH --mem=96G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../../../Logs/%x_%j.out
#SBATCH -e ../../../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Variables

## Path to bbduk
bbduk=

## Are you using paired end reads? true or false
paired=

## List of file IDs. Each line should be like SRA1234 for each run, where
## the run files would be like SRA1234.fastq or SRA1234_R{1,2}.fastq.
id_list=

## Fasta of adaptors to remove
adap=

## Path to directory containing fastq files
input=

## Path to output directory
output=

## Number of bases to force trim from the start
ltrim=

## Size of adapter kmer to look for
kmer=

## Minimum size of adapter kmer to look for
min_kmer=

## Minimum quality score to accept
min_qual=

## Minimum length read to accept
min_len=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Functions

function handle_out {
    local mod_out=$1
    local old=1

    while true; do
        if [ ! -d $1 ]; then
            mkdir $1
            break
        else
            while true; do
                if [ ! -d ${mod_out} ]; then
                    mv $1 ${mod_out}
                    mkdir $1
                    break
                else
                    mod_out=$1"_old${old}"
                    ((old+=1))
                fi
            done
            break
        fi
    done
}

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Code Body
date

## Handle previous outputs 
handle_out ${output}

## Optimize cores
if [ "${paired}" = true ]; then
    jobs_list=$(( $(wc -l < ${id_list}) * 2 ))
else
    jobs_list=$(wc -l < ${id_list})
fi
echo ${jobs_list}

cpus_per_job=$(( ${SLURM_JOB_CPUS_PER_NODE} / ${jobs_list} ))

if [ ${cpus_per_job} = 0 ]; then
    cpus_per_job=1
fi
echo ${cpus_per_job}

jobs_max=$(( ${SLURM_JOB_CPUS_PER_NODE} / ${cpus_per_job} ))
echo ${jobs_max}

## Create commands.list:
if [ "${paired}" = true ]; then
    for line in $(cat ${id_list}); do
        forward=${line}"_1.fastq"
        reverse=${line}"_2.fastq"
        echo "${bbduk} in1=${input}/${forward} in2=${input}/${reverse} out1=${output}/${forward} out2=${output}/${reverse} ref=${adap} threads=${cpus_per_job} forcetrimleft=${ltrim} ktrim=r k=${kmer} mink=${min_kmer} qtrim=r trimq=${min_qual} minlen=${min_len} trimpolya=5 trimpolyg=5 maq=25 > /dev/null 2>&1" | tee -a commands.list
    done
else
    for file in ${input}/*.fastq; do
        echo "${bbduk} in=${input}/${file} out1=${output} ref=${adap} threads=${cpus_per_job} forcetrimleft=${ltrim} ktrim=r k=${kmer} mink=${min_kmer} qtrim=r trimq=${min_qual} minlen=${min_len} trimpolya=5 trimpolyg=5 maq=25 > /dev/null 2>&1" | tee -a commands.list
    done
fi

## Run commands
parallel -j ${jobs_max} < commands.list
mv commands.list ${output}

date
