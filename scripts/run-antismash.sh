#!/bin/bash

# Taken from https://unix.stackexchange.com/a/505342
helpFunction()
{
  echo ""
  echo "Usage: $0 -d data_dir -t num_threads"
  echo -e "\t-d Working directory that will contain the data files"
  echo -e "\t-t Number of threads to use"
  exit 1 # Exit script after printing help
}

while getopts "d:t:" opt
do
  case "$opt" in
    d ) data_dir="$OPTARG" ;;
    t ) num_threads="$OPTARG" ;;
    ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
  esac
done

# Print helpFunction in case parameters are empty
if [ -z "$data_dir" ] || [ -z "$num_threads" ]
then
  echo "Some or all of the parameters are empty";
  helpFunction
fi

# ---------------------------------------------------------------------------- #

files_list=$(find $data_dir/raw/* -name "*-MAG-*.fasta" -type f -maxdepth 2)

for mag_file in $files_list; do

  # Get sample name as directory name
  sample_dir=$(dirname $mag_file)

  # Get MAG name from filename
  mag_name=$(echo $mag_file | rev | cut -d- -f1,2 | rev | cut -d. -f1)

  # Get sample name and GFF file path from MAG file
  sample_name=$(basename ${mag_file//"-${mag_name}.fasta"/})
  gff_file=${mag_file//"-${mag_name}.fasta"/"-genes.gff"}

  # Create output directory if it does not exist
  study_dir=$(dirname $sample_dir)
  output_dir=$data_dir/antismash/$sample_name/$mag_name
  mkdir -p $output_dir

  if [ ! -e "$gff_file" ]; then
    echo "${gff_file} does not exist"
    continue
  fi

  # Run antiSMASH
  antismash \
    --taxon bacteria \
    --cpus $num_threads \
    --verbose \
    --output-dir $output_dir \
    --output-basename $mag_name \
    --genefinding-gff3 $gff_file \
    $mag_file

done
