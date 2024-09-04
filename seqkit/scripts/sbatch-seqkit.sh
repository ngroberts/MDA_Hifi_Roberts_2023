#!/bin/bash
#SBATCH --job-name=seqkit
#SBATCH --mem=50G
#SBATCH -c 5 #cores per task
#SBATCH -n 1 #tasks
#SBATCH -N 1 #nodes
#SBATCH -o slurm_output-seqkit.%J
#SBATCH -e slurm_error-seqkit.%J
#SBATCH -p threaded
#SBATCH --qos threaded
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ngroberts@crimson.ua.edu

#Define the Hifi reads and the assembly
HIFI="$1"
ASSEMBLY="$2"

#Use seqkit to extract the first 500 bases and the last 500 bases from the fasta file.
/grps2/kmk/Nick/2024-02-27_MDA_Seqkit_Samtools/scripts/seqkit subseq -r 1:500 $HIFI > $HIFI"_first_500bp.fasta"
/grps2/kmk/Nick/2024-02-27_MDA_Seqkit_Samtools/scripts/seqkit subseq -r -500:-1 $HIFI > $HIFI"_last_500bp.fasta"

#Use sed to add a _1 and _2 to the first and last read sets
sed -i '/>/s/$/_1/g' $HIFI"_first_500bp.fasta"
sed -i '/>/s/$/_2/g' $HIFI"_last_500bp.fasta"

#Export the reads and run the minimap2 script which requires more resources

LEFT=$HIFI"_first_500bp.fasta"
RIGHT=$HIFI"_last_500bp.fasta"

#Run minimap command exporting all the variables that we produced here
sbatch --export=ALL,HIFI=$HIFI,LEFT=$LEFT,RIGHT=$RIGHT,ASSEMBLY=$ASSEMBLY /grps2/kmk/Nick/2024-02-27_MDA_Seqkit_Samtools/scripts/sbatch-minimap2.sh
