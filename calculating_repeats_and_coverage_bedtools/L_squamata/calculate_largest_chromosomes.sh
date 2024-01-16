#!/bin/bash

# Input bedfile
bedfile="Lep_squam_GC_repeats_coverage.bed"

# Output chromosome sizes file
chrom_sizes="chromosome_sizes.txt"

# Check if the bedfile exists
if [ ! -f "$bedfile" ]; then
  echo "Bedfile not found: $bedfile"
  exit 1
fi

# Extract and sort unique chromosome names
chromosomes=$(awk '{print $1}' "$bedfile" | sort -u)

# Loop through the chromosomes and find the maximum end position
> "$chrom_sizes"  # Create an empty chromosome sizes file

for chrom in $chromosomes; do
  max_end=$(awk -v chrom="$chrom" '$1 == chrom { if ($3 > max) max = $3 } END { print max }' "$bedfile")
  echo "$chrom $max_end" >> "$chrom_sizes"
done

echo "Chromosome sizes have been written to $chrom_sizes"

