BLASTn was run via command line using the following commands:

makeblastdb -in ${fasta1} -dbtype nucleotide > ${blast_db}

blastn -db ${blast_db} -query ${fasta2} -outfmt 6 -out ${blast_out}
