#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Variables
## Fasta to annotate
fasta=

## Bed file of repeats
bed=

## Region to annotate (CHROMOSOME:START-END)
region=

## Output 
out=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Code Body
date

moddotplot static -f ${fasta} \
    -b ${bed} \
    --region ${region} \
    -o ${out}

date

