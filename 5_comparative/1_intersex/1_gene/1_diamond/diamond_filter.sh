#!/bin/awk -f
## GOAL
## Filter diamond outputs to meet quality cutoff
## USAGE
## ./script.sh <2 col tsv of gene name and longest iso length> <diamond output>


BEGIN {
    OFS = "\t"
}

FNR == NR {
    a[$1] = $2
    next
}

{
    if ($3 > 90) {
        if ($11 < 1e-10) {
            if ($4/a[$1] > .8) {
                print $0
            }
        }
    }
}
