# BIOCB 6840 Final Project
Meridia Jane Bryant, NBB 2^nd^ Year, mb2836

## Intro
-----
This repo contains the code used to assembly, annotate and perform various analyses on the *Poecilia reticulata* genome. By following it, one may generate an assembly from their own data using the same method as was used for this project. 

Due to the unpublished and sizable nature of the source data used, the user will need to provide their own data, as the original data is not provided.

## Workflow
---
Below I give general advice of the purpose and instructions for each script. Many have headers for use with the SLURM job manager, though these should be updated or removed to reflect the user's information and execution environment.

For almost all scripts, there is a function or export section the user should update to reflect the location of the resources as labeled. In the case of export lines, the intended replacement is indicated in the respective step's documentation below.

Some scripts expect a module system (look for 'module load XXX'), if one is not prepared on your system, comment the module load lines and ensure the depedencies are in your path.

### 1_read_prep
--- 
Prepares reads for assembly by removing PacBio adaptors and contaminated reads.

#### 1_adaptor_removal
---
adaptor_removal.sh
    : Removes reads wth adaptor sequence from PacBio reads.

To run, one should update the 'export' paths to reflect the location of pigz and HifiAdaptorFilt. Afterwards, execute the script on the command line.


read_metrics.sh
    : Make initial assembly stats file of haplotigs. 

To run, update the '745000000' value to reflect the literature estimated genome's size. Afterwards, execute the script on the command line.

#### 2_contam_removal
---
##### 1_initial_build
---
hifi_contam_removal.sh
    : Generate initial assembly to identify contaminants in.

Execute the script via CLI or SLURM.

##### 2_prep
---
prep_contam_removal.sh
    : Generates extensive metrics and alignmentsfor use in blobtools contamination filtering.

To run, uncomment commented code and update threads to be within available resources. Afterwards, execute script via CLI or SLURM.

##### 3_blob
---
Launch_BlobtoolsViewer.sh
    : Launches the Blobtools Viewer for assessment of contamination and visualization of metrics.

To run, one should update the source line to reflect the location of their bloobtools conda environment, the export line to blobtools path, the port to the desired port, and the '/local/storage/Blob_Datasets' to their desired output location. Afterwards, execute the script via CLI.

### 2_assembly
---
Generate the assembly from the newly filtered reads.

#### 1_size_estimation
---
size_est.sh
    : Estimate the size of the genome from cleaned hifi reads.

To run, update the exports to reflect the location of genomescrope. Afterwards, execute the script via SLURM or replace instances of '$SLURM_CPUS_PER_TASK' with the desired number of threads and execute via CLI.

#### 2_assembly
---
hifiasm.sh
    : Generate triobinned assembly of the offspring.

Execute the script via SLURM or CLI.

remove_circs.sh
    : Remove circular contigs from the assembly.

Execute via SLURM or CLI.

#### 3_metrics
---
metrics.sh
    : Generate metrics of the linear haplotype assemblies for comparison after purging duplicates. 

To run, update BUSCO threads within available resources and execute script via CLI or SLURM.

#### 4_purge
---
purge_dupes.sh
    : Purge duplicate contigs from the assembly and generate BUSCO completeness after purging.

To run, update BUSCO threads within available resources and execute script via CLI or SLURM.

#### 5_metrics2
---
metrics2.sh
    : Generate metrics of the purged haplotype assemblies for comparison to the unpurged assembly.

To run, update the '745000000' value to reflect the literature estimated genome's size. Afterwards, execute the script via CLI or SLURM.

**IMPORTANT:** From this point onward, select the more complete assembly of the purged and unpurged assemblies, then use those assemblies for the remainder of the workflow. Our assembly had a more complete unpurged assembly and the variable labels reflect this, but if the purged assembly is more complete use that instead.

#### 6_alignment
---
alignment.sh
    : Align hifi reads to the selected assembly for sanity checking.

To run, update '-t 30' and '-@ 30' of minimap and samtools respectively to reflect available threads, then execute via CLI or SLURM.

### 3_scaffolding
---
Generate scaffolds and correct misassemblies.

scaffolding.sh
    : Generate scaffold from contigs and pre-existing assembly.

To run, uncomment the commented lines of code. Execute the script via SLURM or replace instances of '$SLURM_CPUS_PER_TASK' with the desired number of threads and execute via CLI.


metrics.sh
    : Generate metrics for newly scaffolded assembly.

To run, adjust '719994475' to reflect the previously calculated genome size, adjust number of BUSCO threads ('-c 90') to match available resources, and uncomment the commented lines of code. Afterwards, execute via SLURM or CLI. 

mapping.sh
    : Generate alignments for use in cleanup and orientation of scaffolds.

To run, modify the ref variable to reflect whichever reference genome you are using (the Kunster and Du guppy assemblies were used in our assembly), then execute via SLURM or CLI.

#### cleanup_and_reorient
---
Percent_Scaf_to_Chr.py
    : Calculate percentage alignment of a given scaffold to reference chromosomes from alignment data.

This script is drawn upon by cleanup.sh, but does need to be run independently to use scaf_assessment.sh. It is recommended to use a python venv, though not required. To run, provide an alignment via standard input and execute via CLI.

scaf_assessment.sh
    : Check whether the contigs have the same best chromosome alignment as the scaffold they are placed within.

Execute via CLI or SLURM.

cleanup.sh
    : Automated process for correcting orientation and assigning names relative to a reference for scaffolds.

The line below must be modified to reflect which components of the reference are the chromosomes (in order). Execute the script via SLURM or replace instances of '$SLURM_CPUS_PER_TASK' with the desired number of threads and execute via CLI.

```
## Orient scaffolds
### Make list of scaffolds to reverse complement
for i in {31..53}
do
	grep -f chr_scafs.txt scaf2ref.asm5.PAF | grep "NC_0243${i}" | sort -k10,10n | tail -1 | awk '($5 == "-"){print $1}' >> to_reverse.txt
done
```

manual_touchups.sh
    : Manual correction of orientation should cleanup.sh be incorrect.

To run, uncomment the commented lines of code. Execute the script via SLURM or replace instances of '$SLURM_CPUS_PER_TASK' with the desired number of threads and execute via CLI.

### 4_annotation
---
Generate annotations for the scaffolded and corrected assembly.

#### 1_repeat_mask
---
masking.sh
    : Annotate repeats and mask genome.

To run, uncomment the commented lines of code, and adjust the paths in each of the singularity calls to reflect the true location of their respective container. Execute the script via SLURM or replace instances of '$SLURM_CPUS_PER_TASK' with the desired number of threads and execute via CLI. 

#### 2_gene_annotation
---
braker.sh
    : Annotate genes using long read RNA, short read RNA, and protein databases.

To run, change species names and databases if relevant. Output files will reflect *Poecilia reticulata*'s species name, but may be adjusted. Execute the script via SLURM or replace instances of '$SLURM_CPUS_PER_TASK' with the desired number of threads and execute via CLI.

reorient.py
    : Reorient GFF3 annotation files.

In the event that annotation was performed on an unoriented assembly, this script may be used to manually flip chromosomes around to reorient them. To run, execute via CLI in the format:

```
reorient.py -i [gff3] -s [tsv of sequences to flip and their length, one per line] -o [output]
```

#### 3_utrs
---

isoseq_cluster.sh
    : Clusters isoseq data for use in PASA.

To run, adjust paths in format of: 

```
[isoseq] cluster2 [input.bam] [output.bam]
```

Execute via CLI.

run_add_UTRs_PASA.sh
    : Wrapper script to add UTRs via PASA.

To run, execute via CLI in the format of: 

```
run_add_UTRs_PASA.sh --align-cofig [path to pasa config file with transdecoder disabled] --annot-config [path to pasa config file with transdecoder enabled] -g [genome] -a [gff3 of braker annotations] -t [fasta of clustered isoseq transcripts]
```

#### 4_functional
---
Primarily conducted via BLAST2GO, scripts contained here are to identify names from BLAST2GO output.

name_gen2.sh
    : Identify likely gene symbols from BLAST2GO output.

Execute via CLI in the format of:

```
name_gen.sh [BLAST2GO mapping export] [output] [threads]
```

update_gene_names.py
    : Updates GFF3 gene names using a two column TSV of geneid and gene symbol.

Execute via CLI in the format:

```
update_gene_names.py [gene_names.tsv] [annotations.gff3] [output.gff3]
```

#### 5_msy
---
##### 1_kmer
---
sexed_kmers.sh
    : Generate a fasta of sex specific kmers.

To run, uncomment the commented code and execute via CLI or SLURM. In our project, we performed additional filtering of the female kmers by subtracting kmers generated from the paternal reads as well, using the same commands as in this script.

mapping_sexed_kmers.sh
    : Generate alignments of sex specific kmers to a given genome.

Execute the script via SLURM or replace instances of '$SLURM_CPUS_PER_TASK' with the desired number of threads and execute via CLI.

The results of mapping_sexed_kmers.sh may be binned using tools such as awk, as follows:

```
awk '/[CHROMOSOME TO BIN]/' [mapping output] > [output.tsv]

awk 'BEGIN {bin=1;count=0;val=0} {{count=count+1;val=val+$3} if (count==[BIN SIZE]) {print $1"\t"bin"\t"val/count;count=0;val=0;bin=bin+1}} END {if (count!=0) {print $1"\t"bin"\t"val/count;count=0}}' [output.tsv] > [output.binned.tsv]
```

##### 2_illumina
---
bbduk.sh
    : Clean up illumina reads by removing regions of low quality and adaptors.

Execute via SLURM or CLI.

illumina_cov.sh
    : Generate sex specific illumina coverage per base.

To run, first modify the value of the '-R' flag in baw-mem2 to match your read headers. Execute the script via SLURM or replace instances of '$SLURM_CPUS_PER_TASK' with the desired number of threads and execute via CLI.

The results of illumina_cov.sh may be binned using tools such as awk, as follows:

```
awk '/[CHROMOSOME TO BIN]/' [mapping output] > [output.tsv]

awk 'BEGIN {bin=1;count=0;val=0} {{count=count+1;val=val+$3} if (count==[BIN SIZE]) {print $1"\t"bin"\t"val/count;count=0;val=0;bin=bin+1}} END {if (count!=0) {print $1"\t"bin"\t"val/count;count=0}}' [output.tsv] > [output.binned.tsv]
```

##### 3_fst
---
picard_dedupe.sh
    : Deduplicate sequence alignment to prepare for FST calculation.

Execute via SLURM or CLI.

gatk_haplotcaller.sh
    : Generate a VCF file for FST calculation.

Execute via SLURM or CLI.

freebayes.sh
    : Calculate FST from VCF.

To run, adjust miniconda path to reflect true path to miniconda. Execute via SLURM or CLI.

The results of freebayes.sh may be binned using tools such as awk, as follows:

```
awk '/[CHROMOSOME TO BIN]/' [mapping output] > [output.tsv]

awk 'BEGIN {bin=1;count=0;val=0} {{count=count+1;val=val+$3} if (count==[BIN SIZE]) {print $1"\t"bin"\t"val/count;count=0;val=0;bin=bin+1}} END {if (count!=0) {print $1"\t"bin"\t"val/count;count=0}}' [output.tsv] > [output.binned.tsv]
```

#### 6_centromere
---
moddotplot.sh
    : Generate tandem repeat graph to identify the centromere.

Execute script via CLI.

#### 7_telomere
---
tidk.sh
    : Identify telomere sequence and graph location.

To run, comment out the second half of the script, execute the first half via CLI, then fill in the repeat variable and run the second half.

### 5_comparative
---
Generate comparative analyses between both the phased sex chromosomes (1_intersex) and the current/past assemblies (2_interassembly).

#### 1_intersex
---
##### 1_gene
---
###### 1_diamond
---
The following scripts take a DIAMOND BLAST between the maternal and paternal haplotypes as input. You may generate this using DIAMOND in the CLI, generating one database per haplotype and then blasting pat to matdb and mat to patdb. For command format, please check DIAMOND's github.

find_longest_iso.sh
    : Generate a TSV of the longest isoform for each gene in a FASTA file.

Execute this awk script via CLI in the format:

```
find_longest_iso.sh [fasta] > [output]
```

diamond_filter.sh
    : Retrieve diamond results that match the criteria of: >90% identity, > 80% query length, and E value < 1e-10.

Execute this awk script via CLI in the format:

```
script.sh [2 col tsv of gene name and longest iso length] [diamond output]
```

###### 2_blastn
---
See readme.txt

###### 3_orthofinder
---
orthofinder.sh
    : Run orthofinder to identify orthologues between maternal and paternal haplotypes.

Execute the script via SLURM or replace instances of '$SLURM_CPUS_PER_TASK' with the desired number of threads and execute via CLI.

##### 2_te
---
rat.py
    : R.A.T. or (Repeatmasker Annotation Tabler) summarizes the annotation of Repeatmasker into a clean table.

Execute via CLI in the format:

```
rat.py -i [repeatmasker .out file] -o [output file]
```

Analyses may then be made by comparing a maternal and paternal table of TEs.

#### 2_interassembly
---
mapping.sh
    : Generates alignments of different assemblies.

Execute via CLI or SLURM.

Analyses may then be made by plotting alignments to determine match of assemblies to one another.

### 6_graphing
---
**IMPORTANT:** Each of these scripts were run in RStudio, it is highly recommended to continue to do so given the Rmarkdown format.

length_graphs.Rmd
    : Generate graph of chromosome lengths.

To run, provide a csv with one chromosome per row, and one assembly's length for that chromosome per column. Afterwards, execute via RStudio.

mapping.Rmd
    : Generate dotplots of assembly alignments

To run, provide PAF files of alignments between each haplotype and assembly, as well as order that the chromosomes should be placed in for each graph. Afterwards, update the dotplot functions with the new alignment and order inputs and execute via RStudio. 

msy_graphing.Rmd
    : Generate coverage depth plots of sex based illumina and kmer alignments. Also graph FST values.

To run, provide binned kmer coverage, fst, or illumina coverage tsvs as input and designate the dataframes you would like to use in each code block. Afterwards, execute via RStudio.

te_comparisons.Rmd
    : Generate plot of TE differences between haplotypes.

To run, provide output from rat.py as input and update "{m,p}atte_origin" lines with the new inputs. Execute via RStudio.
