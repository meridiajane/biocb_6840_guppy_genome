#!/bin/bash
#SBATCH --job-name=con_scaf_comparison
#SBATCH --mail-user=mb2836@cornell.edu
#SBATCH --mail-type=ALL
#SBATCH -c 10
#SBATCH --mem=50G
#SBATCH --partition=regular
#SBATCH --qos=regular
#SBATCH -o ../../../../Logs/%x_%j.out
#SBATCH -e ../../../../Logs/%x_%j.err

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Variables

## Best match file for the contigs
bmc=

## Best match file for the scaffolds
bms=

## AGP for scaffolding
agp=

### Output name
out=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Code Body

printf "contig\tBest Match Contig\tScaffold\tBest Match Scaffold\tResult\n" > ${out}

tail -n+3 ${agp} | while read line; do
    
    con=$(echo ${line} | awk '{print $6}')
    sca=$(echo ${line} | awk '{print $1}')

    if [[ ${con} =~ ^[0-9]+$ ]]; then
        continue
    fi

    bm1=$(tail -n+2 ${bmc} | awk -v con="${con}" '$0 ~ con' | sort -rn -k 5,5 | head -n1 | awk '{print $2}')
    bm2=$(tail -n+2 ${bms} | awk -v sca="${sca}" '$0 ~ sca' | sort -rn -k 5,5 | head -n1 | awk '{print $2}')

    if [[ "${bm1}" = "${bm2}" ]]; then
        result="True"
    else
        result="False"
    fi

    printf "${con}\t${bm1}\t${sca}\t${bm2}\t${result}\n" >> ${out}

done


