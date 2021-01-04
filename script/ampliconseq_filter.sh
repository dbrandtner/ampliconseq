#!/bin/bash
#
#This script has default arguments you can modify submitting parameters as follow.
#
#Usage: ampliconseq_filter.sh REF PIDENT
#
#Parameters:
#	REF = reference file path (please use /reference dir)
#	PIDENT = blast output %identity to filter with
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
#Runs Awk, sort, uniq, sed to filter for desidered similiarity threshold and edit outputfile in tsv format.


#runtime start.
start=`date +%s`


#Variables declaration.
REF=$1
PIDENT=$2
ID=id/id_name.txt
AWKSCRIPT=script/filter_$1.awk
SEDSCRIPT=script/tab_edit.sed


#Stop on any error.
set -ue


#PL function declaration.
function PL  {
	#APPLY FILTER FOR desidered similarity threshold.
	#Counts and sed edits output in .tsv format.
	awk 'BEGIN {FS=OFS="\t"} {if($2 >= "'"$1"'") { print $1,$2="'"$3"'",$3="'"$1"'"} }' tsv/$3_result$2_f.tsv | sort | uniq -c | sort -n | sed -f script/tab_edit.sed > results/$3_result$2_$1.tsv
}; export -f PL


#Calling PL function to run with parallel command.
cat $ID | parallel "PL ${PIDENT} ${REF} '"{}"'"


#runtime end and calculation.
end=`date +%s`
runtime=$((end-start))
echo "script runtime: $runtime sec"
