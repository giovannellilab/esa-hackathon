#!/bin/bash

#SBATCH --job-name="genelab"
#SBATCH --time=160:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G
#SBATCH --partition=parallel

# Taken from https://unix.stackexchange.com/a/505342
helpFunction()
{
  echo ""
  echo "Usage: $0 -d data_dir -s study_id"
  echo -e "\t-d Working directory that will contain the data files"
  echo -e "\t-s OSDR study ID"
  exit 1 # Exit script after printing help
}

while getopts "d:s:" opt
do
  case "$opt" in
    d ) data_dir="$OPTARG" ;;
    s ) study_id="$OPTARG" ;;
    ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
  esac
done

# Print helpFunction in case parameters are empty
if [ -z "$data_dir" ] || [ -z "$study_id" ]
then
  echo "Some or all of the parameters are empty";
  helpFunction
fi

# ---------------------------------------------------------------------------- #

bash data-pipeline-genelab-geomosaic.sh \
  -d $data_dir \
  -s $study_id \
  -t $SLURM_CPUS_PER_TASK
