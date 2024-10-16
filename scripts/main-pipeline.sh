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

# Data pipeline: GeneLab
bash data-pipeline-genelab.sh -d $data_dir -s $study_id -t $num_threads

# Data pipeline: NCBI
bash data-pipeline-ncbi.sh -d $data_dir -s $study_id -t $num_threads

# Analysis pipeline: antiSMASH
bash run-antismash.sh -d $data_dir/OSD-${study_id}/genelab/ -t $num_threads
bash run-antismash.sh -d $data_dir/OSD-${study_id}/ncbi/ -t $num_threads
