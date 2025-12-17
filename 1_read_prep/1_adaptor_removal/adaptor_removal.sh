# Removes reads with adaptor sequence from PacBio sequence.
#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
export PATH=/programs/HiFiAdapterFilt:/programs/pigz-2.4:$PATH
export PATH=/programs/HiFiAdapterFilt/DB:$PATH
#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Path to hifi reads bam file
reads=

# Threads to use for filtering
threads=90 # number of threads to use for filtering, default to 8

# Path to hifi reads fastq, can stay gzipped
fastq=

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
ln -s ${reads} hifi_reads.bam


# Filter reads containing adaptors and make fastq
pbadapterfilt.sh -p ./hifi_reads -t ${threads}

# Can unzip or leave gzipped
pigz -d ./hifi_reads.filt.fastq.gz


# Copy reads to working project directory 
mkdir -p ~/1_ReadPrep/1_AdaptorPurged_fastq
#cp [HiFi_Reads.filt.fastq] ~/1_ReadPrep/2_AdaptorPurged_fastq
