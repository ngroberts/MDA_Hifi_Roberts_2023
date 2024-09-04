#!/bin/bash
#SBATCH --job-name=remove_reads
#SBATCH --mem=50G
#SBATCH -c 5 #cores per task
#SBATCH -n 1 #tasks
#SBATCH -N 1 #nodes
#SBATCH -o slurm_output-remove.%J
#SBATCH -e slurm_error-remove.%J
#SBATCH -p highmem
#SBATCH -q highmem
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ngroberts@crimson.ua.edu
module load bio/samtools/1.10

fasta_file=$1
reads_removed=$2

samtools faidx $1

awk '{print $1}' "$1".fai | grep -v -f "$2" > reads_retained.txt

samtools faidx -o $1_filtered $1 -r reads_retained.txt
