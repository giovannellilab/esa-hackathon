#!/bin/bash

# Taken from https://unix.stackexchange.com/a/505342
helpFunction()
{
  echo ""
  echo "Usage: $0 -d data_dir -s study_id -t num_threads"
  echo -e "\t-d Working directory that will contain the data files"
  echo -e "\t-s OSDR study ID"
  echo -e "\t-t Number of threads to use"
  exit 1 # Exit script after printing help
}

while getopts "d:s:t:" opt
do
  case "$opt" in
    d ) data_dir="$OPTARG" ;;
    s ) study_id="$OPTARG" ;;
    t ) num_threads="$OPTARG" ;;
    ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
  esac
done

# Print helpFunction in case parameters are empty
if [ -z "$data_dir" ] || [ -z "$study_id" ] || [ -z "$num_threads" ]
then
  echo "Some or all of the parameters are empty";
  helpFunction
fi

# ---------------------------------------------------------------------------- #

# Create contigs-db for each species
anvi-gen-contigs-database \
    -T $num_threads \
    -f GLDS-69_GMetagenomics_5492_IG2SW-M_F1_L2_NORM_GC-MAG-3.fasta \
    --project-name PROJECT_NAME_3 \
    -o contigs-MAG-3.db

anvi-gen-contigs-database \
    -T $num_threads \
    -f GLDS-69_GMetagenomics_5492_IG2SW-M_F1_L2_NORM_GC-MAG-4.fasta \
    --project-name PROJECT_NAME_4 \
    -o contigs-MAG-4.db

# Combine contigs-db
anvi-script-gen-genomes-file \
    --input-dir . \
    --output-file external-genomes.txt

anvi-gen-genomes-storage \
    -e external-genomes.txt \
    -o PROJECT-GENOMES.db

# Create pangenome
anvi-pan-genome -g PROJECT-GENOMES.db -n PROJECT_NAME

# Display pangenome
anvi-display-pan -p PROJECT_NAME/PROJECT_NAME-PAN.db -g PROJECT-GENOMES.db
