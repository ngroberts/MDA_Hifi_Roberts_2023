

#### Download the transcriptome data you want to use
```bash
/home/apodomenia/bin/sratoolkit.2.11.3-ubuntu64/bin/fasterq-dump --split-files SRR1982110
```

#### Trim and filter transcriptome data
```bash
export HERE=`pwd`
mkdir q35
/home/apodomenia/bin/TrimGalore-0.6.7/trim_galore --cores 12 -q 35 --illumina --fastqc --length 50 --trim-n -o $HERE/q35 L_reads.fq
cp q35/L_reads_val.fq ..
```

#### Make RepeatModeler database
```bash
/home/apodomenia/bin/RepeatModeler-2.0.1/BuildDatabase -engine rmblast -name Lepidodermella_squamata_repeats Lepidodermella_sp.asm.bp.p_ctg_filtered.fasta
```
#### Run RepeatModeler
```bash
RepeatModeler -pa 15 -engine rmblast -LTRStruct -database Lepidodermella_squamata_repeats 2>&1 | tee repeatmodeler.log
```

#### Run RepeatMasker
GC content should be optimized for your organism if you specify the -gc flag!
```bash
/home/apodomenia/bin/RepeatMasker/RepeatMasker -parallel 15 -engine rmblast -gc 45 -lib /home/apodomenia/Nick/2021-12-06_Lsquam_annotation/RM_105265.MonDec61619452021/consensi.fa.classified Lepidodermella_sp.asm.bp.p_ctg_filtered.fasta -xsmall
```
#### Generate STAR genome - make sure to use the repeat masked genome!
```bash
mkdir star_genome
STAR --runThreadN 12 --runMode genomeGenerate --genomeDir star_genome --genomeFastaFiles Lepidodermella_sp.asm.bp.p_ctg_filtered.fasta.masked
```
#### Run STAR mapping
```bash
STAR --runThreadN 12 --limitGenomeGenerateRAM 65500000 --chimSegmentMin 50 --outFilterType BySJout --limitOutSJcollapsed 2000000 --genomeDir star_genome --readFilesIn $HERE/L_reads_trimmed.fq
```
#### Make BAM from SAM and get rid of SAM
```bash
samtools view -bS Aligned.out.sam > RNAseq.bam
rm -rf *.sam
```
#### Run BRAKER
```bash
braker.pl --cores 12 --softmasking --UTR=on --crf --makehub --email ngroberts@crimson.ua.edu --gff3 --species=Lepidodermella_squamata_2021-12-09 --genome Lepidodermella_sp.asm.bp.p_ctg_filtered.fasta.masked --bam RNAseq.bam
```
#### Analyze stuff:
```bash
./selectSupportedSubsets.py --fullSupport gene_models_with_full_support.gtf --noSupport gene_models_with_no_support.gtf --fullSupport gene_models_with_full_support.gtf --anySupport gene_models_with_any_support.gtf augustus.hints.gtf hintsfile.gff
```
