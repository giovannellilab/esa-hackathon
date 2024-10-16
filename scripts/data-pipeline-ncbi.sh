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

# Get genelab data directory
genelab_dir=$(realpath ${data_dir}/OSD-${study_id}/genelab/raw)

# Change to ncbi data directory
wd=${data_dir}/OSD-${study_id}/ncbi/raw
mkdir -p $wd && cd $wd

# Check this answer: https://unix.stackexchange.com/a/580545
while IFS='' read -r LINE || [ -n "${LINE}" ]; do

  echo "[+] Processing species: ${LINE}"

  species_name=$(echo "${LINE}" | tr "[:upper:]" "[:lower:]" | tr " " "_")

  ncbi-genome-download \
    --genera "${LINE}" \
    --section refseq \
    --assembly-levels complete \
    --format "fasta,gff" \
    --parallel $num_threads \
    --output-folder $species_name \
    --flat-output \
    --progress-bar \
    bacteria

  # Extract files
  gunzip -d ${species_name}/*.gz

  # Fit OSDR format
  rename "s/_genomic.fna$/-MAG-1.fasta/" ${species_name}/*.fna
  rename "s/_genomic.gff$/-genes.gff/" ${species_name}/*.gff

  # Add species as prefix
  for filename in $(ls $species_name); do
    mv "$species_name/$filename" "$species_name/${species_name}-${filename}"
  done

done < ${genelab_dir}/OSD-${study_id}-species.txt
