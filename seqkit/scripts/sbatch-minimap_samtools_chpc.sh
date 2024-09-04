#!/bin/bash
#SBATCH --job-name=minimap2
#SBATCH --mem=300G
#SBATCH -c 10 #cores per task
#SBATCH -n 1 #tasks
#SBATCH -N 1 #nodes
#SBATCH -o slurm_output-minimap2.%J
#SBATCH -e slurm_error-minimap2.%J
#SBATCH -p highmem
#SBATCH --qos highmem
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ngroberts@crimson.ua.edu

module load bio/minimap2/2.10
module load python/python3/3.11.7
module load bio/samtools/1.10

#Align reads to assembly using minimap2
#echo "Running minimap2 with the assembly:$ASSEMBLY, and reads $LEFT and $RIGHT"

#minimap2 -ax sr $ASSEMBLY $LEFT $RIGHT > aln_artificial_reads.sam

NAME=`basename $ASSEMBLY | cut -f 1 -d "."`

#First only keep ~uniquely~ mapped reads and then look for reads on differetn contigs, this removes reads that could be ambiguosly mapping other places.
#Hard to say when a read is unique in its mapping as any read could potentially map anywhere with a low score, I filter by score first.
#MAPQ is a probability stat: p_wrong= 10^(-mapq/10) so for example like MAPQ 10 means the probability the map is wrong is 0.1 and for 20 0.01 etc.

samtools view -q 30 aln_artificial_reads.sam > aln_artificial_reads_reliable_mapped.sam

#Run get_mismatch to grab all the full reads whose artifical reads map to different contigs

export SAM=aln_artificial_reads_reliable_mapped.sam

python3 /grps2/kmk/Nick/2024-02-27_MDA_Seqkit_Samtools/scripts/get_mismatch.py > $NAME"_mismatch_reads.txt"

cut -f 4 -d ' ' $NAME"_mismatch_reads.txt" > reads_removed.txt




