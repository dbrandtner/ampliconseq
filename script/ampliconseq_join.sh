#!/bin/bash
#
#This script has default arguments you can modify submitting parameters as follow.
#
#Usage: ampliconseq_join.sh LENGTH PIDENT
#
#Parameters:
#	LENGTH = amplicon target max sequence length in reference file.
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
#Runs FastQC on each file in /raw.
#Runs TrimmomaticPE on each file in /raw with set parameters.
#Runs FastQC on each trimmed file in /trim.
#Runs FastQ-JOIN on each trimmed file in /trim.


#runtime start.
start=`date +%s`


#Variables declaration.
REF=$1
PIDENT=${2:-90}
LENGTH=${3:-50}
RAW=id/raw.txt
ID=id/id_name.txt
AWKSCRIPT=script/filter_$1.awk
SEDSCRIPT=script/tab_edit.sed

#Stop on any error.
set -ue


#Creates a txt file with a list of raw file names.
ls raw > $RAW


#Gets file basename to use in {}.
basename -s _R1_001.fastq.gz raw/*_R1_001.fastq.gz > $ID


#Runs FastQC on raw fastq.gz files
#
#Makes QC analysis and save results in proper directory.
echo "FastQC analysis on raw files"
cat $RAW | parallel fastqc raw/{} -o fastqc/raw


#TRIM reads based on fastqc analysis.
#
#From trimmomatic manual "_R1_001.fastq" is one of the admitted option for -basein.
#
#Prints terminal output &>> because simple > does not work.
echo "Trimmomatic operations"
cat $ID | parallel TrimmomaticPE -phred33 -basein raw/{}_R1_001.fastq.gz -baseout trim/{}_trim.fastq.gz SLIDINGWINDOW:4:20 MINLEN:$LENGTH &>> trim/trimstat.txt 


#Runs FastQC on trimmed _trim_*P.fastq.gz files
#
#Makes QC analysis and save results in proper directory.
echo "FastQC analysis on trimmed files"
cat $ID | parallel fastqc trim/{}_trim_*P.fastq.gz -o fastqc/trim


#FASTQ-JOIN joins reads with a minimum overlap set to LENGTH variable
echo "FASTQ-JOIN operations"
cat $ID | parallel "echo fastq-join -p 8 -m $LENGTH trim/{}_trim_1P.fastq.gz trim/{}_trim_2P.fastq.gz -o joined/{}_%.fastq.gz \> joined/{}_joinstat.txt" | bash


#Runs FastQC on joined _join.fastq.gz files
#
#Makes QC analysis and save results in proper directory.
echo "FastQC analysis on joined files"
cat $ID | parallel fastqc joined/{}_join.fastq.gz -o fastqc/joined

#runtime end and calculation.
end=`date +%s`
runtime=$((end-start))
echo "script runtime: $runtime sec"
