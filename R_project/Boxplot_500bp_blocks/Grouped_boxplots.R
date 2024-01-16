library(ggplot2)
library(tidyverse)
library(cowplot)
library(patchwork)
library(ggpmisc)
library(stats)
library(scales)

##Import bedfiles as tsv.

# Read bedfiles as tsv
C_bed_gc <- read_tsv("Boxplot_500bp_blocks/C_elegans_500bp_blocks_GC_content.bed", col_names = TRUE)
C_bed_mean_cov <- read_tsv("Boxplot_500bp_blocks/C_elegans_MDA_cov_500bp_blocks.bed", col_names = FALSE)

# Join GC content with coverage
C_bed_gc$key <- paste(C_bed_gc$`#1_usercol`, "_", C_bed_gc$`2_usercol`, "_", C_bed_gc$`3_usercol`)

range_amp <- max(C_bed_mean_cov$X4) - min(C_bed_mean_cov$X4)


C_bed_full_stats <-
  C_bed_mean_cov %>% mutate(key = paste(X1, "_", X2, "_", X3)
  ) %>%
  left_join(select(C_bed_gc, key, `5_pct_gc`), by = "key") %>%
  rename(
    contig_name = X1,
    window_start = X2,
    window_end = X3,
    coverage_amp = X4,
    gc_content = `5_pct_gc`
  ) %>%
  mutate(
    normal_mean_amp = (coverage_amp - min(coverage_amp)/ range_amp),
    gc_perc = gc_content * 100,
    gc_position = row_number(),
    ranges = cut(gc_perc, seq(10, 80, 5))
  ) %>%
  group_by(ranges)

#Make grouped boxplot:
ggplot(data = subset(C_bed_full_stats, !is.na(ranges)), aes(x = ranges, y = coverage_amp)) + 
  geom_boxplot(outlier.shape = NA) +
  scale_y_continuous(name = "Coverage") +
  coord_cartesian(ylim = c(0,300)) +
  xlab("GC Percentage") +
  theme_cowplot()
  




