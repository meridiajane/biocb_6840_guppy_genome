#!/bin/awk -f

BEGIN {count=0}                                 # Declare count, to be used as an index

{
    if ($0 ~ />/) {
        gsub(">","",$0)                         # Shorten isoform name to just the gene name
        iso_name = $0                           # Save isoform name
        gsub(/\..*/,"",$0)
        if ($0 != key[count]) {                 # Check to see if the gene has changed, if so, move to new index
            count++
        }
        key[count] = $0
    }
    else if (length > longest[key[count]]) {    # Update longest isoform if new longest is found
            longest[key[count]] = iso_name
    }
}

END {
    for (i=1; i <= count; i++) {                # Return tsv of genes and longest isoform length
        printf key[i]"\t"longest[key[i]]"\n"
    }
}
