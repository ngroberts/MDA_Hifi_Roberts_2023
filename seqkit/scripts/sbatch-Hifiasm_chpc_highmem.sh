#!/bin/bash
#SBATCH --job-name=hifiasm
#SBATCH -n 1 #tasks
#SBATCH -N 1 #nodes
#SBATCH -c 16 #number of cores per task
#SBATCH --mem=800G
#SBATCH -o slurm_output-quast.%J
#SBATCH -e slurm_error-quast.%J
#SBATCH -p highmem
#SBATCH -q highmem
#Make note of version and date:

echo "Hifiasm Version" >> version.txt
hifiasm --version >> version.txt
date >> version.txt

READS="$1"

/kmk/scripts/hifiasm-0.15.2/hifiasm -o $READS".asm" -t 16 $READS
awk '/^S/{print ">"$2"\n"$3}' $READS".asm.bp.p_ctg.gfa" | fold > $READS".asm.bp.p_ctg.fasta"
echo done
