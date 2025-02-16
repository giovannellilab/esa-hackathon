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

# Get utilities scripts directory
utils_dir=$PWD/utils

# Change to genelab data directory
wd=${data_dir}
mkdir -p $wd && cd $wd

# Get list of files (URLs)
python $utils_dir/genelab-get-urls.py --data-dir . --study-id $study_id --raw

# Download all selected files
cat "OSD-${study_id}-urls.txt" | parallel -j$num_threads wget -nv {}

# Remove prefix in all files
rename -d "download?source=datamanager&file=" *

for file in *_raw.fastq.gz; do

  # Fix IDs to avoid errors with Kaiju
  gzip -d -c $file | \
    seqkit replace -p "\.1 |\.2 " -r " " --f-by-name \
      -o ${file%_raw.fastq.gz}_idfixed.fastq.gz

  # Remove raw file to free some storage
  rm $file

done
