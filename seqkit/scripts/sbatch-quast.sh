#!/bin/bash
#SBATCH --job-name=quast
#SBATCH -n 1 #tasks
#SBATCH -N 1 #nodes
#SBATCH -c 16 #number of cores per task
#SBATCH --mem=20G
#SBATCH -o slurm_output-quast.%J
#SBATCH -e slurm_error-quast.%J
#SBATCH -p highmem
#SBATCH -q highmem

me=`whoami`

ASSEMBLY=$1

module load bio/quast/5.0

quast.py -e -m 0 -t 16 --space-efficient $ASSEMBLY
