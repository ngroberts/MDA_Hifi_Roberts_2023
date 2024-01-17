## Calculate repeat amount per non-overlapping window and combine with coverage from the following input:

**Input Files**
1. bedfile from mapping the hifi reads to the genome turned into coverage information for 100kb windows. (See coverage_calculations)
2. bedfile of non-overlapping 100kb regions of the genome
3. bedfile of annotated repeats

As an example I will demonstrate how this was done for L. squamata here:

## Use bedtools merge to merge overlapping repeat regions in the bedfile of your annotated repeats. Otherwise they will be counted multiple times.

> bedtools merge -i Lepidodermella_sp.asm.bp.p_ctg_filtered.fasta.out.bed > Lepidodermella_sp.asm.bp.p_ctg_filtered.fasta.out_merge.bed

## Use bedtools intersect to find regions of overlap between the repeats from the annotated .out.bed file with the -wo option so the number of base pair overlap is computed:

> bedtools intersect -a Lepidodermella_sp_100kb_window.bed -b Lepidodermella_sp.asm.bp.p_ctg_filtered.fasta.out_merge.bed -wo > intersection_repeats.bed

## Calculate the repeat content using awk:

> awk 'BEGIN {OFS = "\t"} {
    region_size = $3 - $2;
    repeat_size += $NF;
    region_id = $1 ":" $2 "-" $3;
    if (prev_region != "" && prev_region != region_id) {
        repeat_percentage = (prev_repeat_size / prev_region_size) * 100;
        print prev_region, repeat_percentage;
        repeat_size = 0;  # Reset repeat_size for the new region
    }
    prev_region = region_id;
    prev_region_size = region_size;  # Store the size of the current region as the previous region size
    prev_repeat_size = repeat_size	
} END {
    if (prev_region != "") {
        repeat_percentage = (prev_repeat_size / prev_region_size) * 100;
        print prev_region, repeat_percentage;
    }
}' intersection_repeats.bed > repeat_content.bed

## Check that this is formatted correctly as a bed file. Its not so use sed to fix it.

> sed -i.bak 's/\:/\t/g; s/\-/\t/g' repeat_content.bed

## Now join the coverage bedfile and the repeat content bedfile and any other bedfiles you have created:

> bedtools map -a repeat_content.bed -b Lepidodermella_sp_100kb_window_coverage.bed -c 4 -o mean > L_squamata_repeat_coverage
> bedtools map -a  L_squamata_repeat_coverage -b Lepidodermella_sp_100kb_window_GC_content.bed -c 5 >Lep_squam_GC_repeats_coverage.bed
 
## For the case of Lepidodermella squamata we did not have pseudomolecules or chromosomes so we had to sort by the largest chromosomes. This requires creating a script to find the largest ones. 

> calculate_largest_chromosomes.sh 
> sort chromosome_sizes.txt chromosome_sizes_sorted.txt

## Then we must sort so its in the order of largest to smallest. 

> bedtools sort -i Lep_squam_GC_repeats_coverage.bed -faidx chromosome_sizes_sorted.txt > Lep_squam_GC_repeats_coverage_sorted.bed 

