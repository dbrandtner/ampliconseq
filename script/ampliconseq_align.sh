#!/bin/bash
#
#This script has default arguments you can modify submitting parameters as follow.
#
#Usage: ampliconseq_align.sh REF
#
#Parameters:
#	LENGTH = amplicon target max sequence length in reference file.
#	REF = reference file path (please use /reference dir)
#	PIDENT = blast output %identity to filter with
#
#**In a future update LENGTH will be obtained from reference file.**
#
#Folders to be present in parent directory:
#	/raw
#	/reference
#	/id
#	/fastqc (subfolder /raw, /trim, /joined)
#	/trim
#	/joined
#	/script
#	/tsv
#	/results (subfolder /allpools)
#
#Assumes raw files have been generated with MiSeq2 Illumina platform.
#Assumes the data is in paired-end format.
#Assumes amplicons have been obtained with nested PCR using degenerate primers.
#Assumes max generated MiSeq2 read length include target sequence length (2 x 150bp).
#
#Runs SEQTK to translate fastq format in FASTA.
#Runs makeblastdb to make custome nucleotde database.
#Runs Blastn on each joined reads file in /joined.
#Runs Awk, Cut to filter reads for retference complete matching and edit result file


#runtime start.
start=`date +%s`


#Variables declaration.
REF=$1
PIDENT=${2:-90}
ID=id/id_name.txt
AWKSCRIPT=script/filter_$1.awk
SEDSCRIPT=script/tab_edit.sed


#Stop on any error.
set -ue


#Gets file basename to use in {}.
basename -s _R1_001.fastq.gz raw/*_R1_001.fastq.gz > $ID

#SEQTK converts fastq to FASTA for blast input.
echo "SEQTK conversion to fasta"
cat $ID | parallel "echo seqtk seq -a joined/{}_join.fastq.gz \> joined/{}_join.fasta" | bash


#BLAST makes custom nucleotide database.
echo "making custom BLAST nucleotides database"
makeblastdb -in reference/$REF.fa -dbtype nucl -parse_seqids


#BLASTN searchs high matching pairs in fasta file.
#outfmt 6
#(use ' ' for bash console, "otherwise too many positional argument" error)
echo "BLASTN search"
cat $ID | parallel blastn -db reference/${REF}.fa -query joined/{}_join.fasta -outfmt "6" -out tsv/{}_result${REF}.tsv -perc_identity ${PIDENT} -subject_besthit -max_target_seqs 1 -num_threads 4


#APPLY FILTER FOR reference max-length MATCH.
echo "AWK filtering for max_length joined_read/reference match"
cat $ID | parallel "echo awk -f ${AWKSCRIPT} tsv/{}_result${REF}.tsv \| cut -f2,3 \> tsv/{}_result${REF}_f.tsv" | bash


#runtime end and calculation.
end=`date +%s`
runtime=$((end-start))
echo "script runtime: $runtime sec"
