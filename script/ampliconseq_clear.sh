#!/bin/bash
#
#This script has default arguments you can modify submitting parameters as follow.
#
#Usage: ampliconseq_clear.sh
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


#Make question to the user.
echo "Clear all results? You will have to repeat filter and allpooltab command."

#Read input from the user.
read -p "Type yes or no [y/n]: " yn

#Conditional statements to clear or not to clear selected directories.
if [[ $yn == "y" ]]
then
	rm results/*.tsv &> out.log
	rm results/allpool/*.tsv &> out.log
	rm out.log
	echo "Clearing done."
else 
	echo "Nothing done. Exit."
fi
