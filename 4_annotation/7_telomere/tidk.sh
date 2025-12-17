#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Variables
## Fasta to annotate
fasta=

## Repeat to use to id telomeres
repeat=

## Output 
out=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Code Body
date

tidk explore ${fasta} > tidk_explore_out.txt

## Run after selecting a repeat from the explore output
## Update paths as needed
tidk search --string ${repeat} \
    --output tidk_search_output

tidk plot --tsv tidk_search_output.tsv \
    --output tidk_plot_output

date

