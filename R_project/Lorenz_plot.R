library(ggplot2)
library(tidyverse)
library(cowplot)
library(patchwork)
library(ineq)
library(gglorenz)


#Calculating Gini scores and lorenz plots using full datasets.

#Read in datasets

amplified_celegans <- read_tsv("C_bed_repeat_amped.tsv")

unamplified_celegans <- read_tsv("C_bed_repeat_unamped.tsv")

l_squamata <- read_tsv("Lep_squam.tsv")

#Make a 'position' column to assign a unique position to each row.

amplified_celegans$position <- 1:nrow(amplified_celegans) 

unamplified_celegans$position <- 1:nrow(unamplified_celegans)

l_squamata$position <- 1:nrow(l_squamata)

#Calculate cumulative sums for C. elegans after joining the datasets

elegans_full <- left_join(amplified_celegans, unamplified_celegans, by = 'position')

position_c_ele = pull(elegans_full, position)

reads_amp_c_ele = pull(elegans_full, X5.x)

reads_non_amp_c_ele = pull(elegans_full, X5.y)

#Make into tibble

lorenz_c_ele_amp <- tibble(position_c_ele, reads_amp_c_ele)
lorenz_c_ele_non_amp <- tibble(position_c_ele, reads_non_amp_c_ele)


#Do the same for L. squamata

position_l_squamata = pull(l_squamata, position)
reads_amp_l_squamata = pull(l_squamata, X5)
lorenz_l_squamata <- tibble(position_l_squamata, reads_amp_l_squamata)

lorenz_from_bam_l_squam <- read_tsv("l_squam_lorenz_bam.tsv")
lorenz_from_bam_l_squam <- lorenz_from_bam_l_squam %>% rename(frac_base_seq = "X-fraction-sequenced-bases", frac_genom_seq = "Y-fraction-genome-covered")

#test

lorenz_l_squamata <- lorenz_l_squamata %>% mutate(source = "lorenz_l_squamata", row_number = row_number()) %>% rename(reads = "reads_amp_l_squamata") %>% select(reads,source,row_number)
lorenz_c_ele_non_amp <- lorenz_c_ele_non_amp %>% mutate(source = "lorenz_c_ele_non_amp", row_number = row_number()) %>% rename(reads = "reads_non_amp_c_ele") %>% select(reads,source, row_number)
lorenz_c_ele_amp <- lorenz_c_ele_amp %>% mutate(source = "lorenz_c_ele_amp", row_number = row_number()) %>% rename(reads = "reads_amp_c_ele") %>% select(reads,source, row_number)

combined_tibble <- bind_rows(lorenz_l_squamata,lorenz_c_ele_non_amp,lorenz_c_ele_amp)

lorenz_total <- ggplot(data = combined_tibble, aes(reads, color = source)) + 
  stat_lorenz(desc = FALSE) +
  theme_cowplot() +
  theme(axis.title.x = element_text(size = 8, vjust = -0.5),
        axis.title.y = element_text(size = 8),
        axis.title.y.right = element_text(size = 8),
        axis.text.y = element_text(size = 8),
        axis.text.x = element_text(size = 8, hjust = 0, vjust = -0.09),
        axis.text = element_text(size = 8)) +
          xlab("Cumulative Share of Reads") +
          ylab("Cumulative Share of Genome") +
          geom_abline(linetype = "dotted")

lorenz_total

x
lorenz_l_squam <- ggplot(data = lorenz_from_bam_l_squam, aes(x = frac_base_seq, y = frac_genom_seq)) + 
  stat_lorenz(desc = FALSE) +
  geom_line() +
  theme_cowplot() +
  theme(axis.title.x = element_text(size = 8, vjust = -0.5),
        axis.title.y = element_text(size = 8),
        axis.title.y.right = element_text(size = 8),
        axis.text.y = element_text(size = 6),
        axis.text.x = element_text(size = 6, hjust = 0, vjust = -0.09),
        axis.text = element_text(size = 6)) +
  xlab("Cumulative Share of Reads") +
  ylab("Cumulative Share of Genome") +
  geom_abline(linetype = "dotted")

lorenz_l_squam


save(lorenz_total, file = "ggplot_objects/lorenz_total")
lorenz_total

gini_l_squam <- round(ineq(lorenz_l_squamata$reads), 2)
gini_c_ele_amp <- round(ineq(lorenz_c_ele_amp$reads), 2)
gini_c_ele_non_amp <- round(ineq(lorenz_c_ele_non_amp$reads), 2)


df.1 <- as.data.frame(lorenz_c_ele_non_amp)
df.2 <- as.data.frame(lorenz_c_ele_amp)

testGL(df.1, df.2, ipuc = "reads", generalized = TRUE, hhcsw = "row_number", hhsize)

       