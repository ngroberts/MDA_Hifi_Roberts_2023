#!/bin/bash
#SBATCH --job-name=BUSCO
#SBATCH --mem=100G
#SBATCH -n 1 #tasks
#SBATCH -N 1 #nodes
#SBATCH -c 16 #cores per task
#SBATCH -o slurm_output-BUSCO.%J
#SBATCH -e slurm_error-BUSCO.%J
#SBATCH -p highmem
#SBATCH -q highmem
#SBATCH --mail-type=ALL
#SBATCH --mail-user=

module load bio/busco
module load bio/augustus/3.3.2

READS=$1

export BUSCO_CONFIG_FILE="/kmk/scripts/busco/config.ini"
export AUGUSTUS_CONFIG_PATH="/kmk/scripts/augustus-3.3.2/config"

#You may want to change "metazoa" to "mollusca" or vice versa for the different databses we are likely to use
#This script uses the new "--long" feature that is more sensitive
busco -c 16 -m genome --long --offline -l /kmk/databases/metazoa_odb10 -i $READS -o BUSCO_scaffolds.fasta

