library(ggplot2)
library(tidyverse)
library(cowplot)
library(patchwork)
library(ggpmisc)
library(stats)
library(RColorBrewer)

#Load in the dataset
Lep_squam <- read_tsv("Lep_squam_GC_repeats_coverage_sorted.bed", col_names = FALSE)

#Remove outliers using 1.5* IQR for coverage comment out this block to keep outliers.
# Q <- quantile(Lep_squam$X5, probs=c(.25, .75), na.rm = FALSE)
# iqr <- IQR(Lep_squam$X5)
# up <- Q[2]+1.5*iqr
# low <- Q[1]-1.5*iqr
# 
# Lep_squam <- Lep_squam %>% filter(X5 < up_amp, X5 > low_amp)

#Find the range of the coverage for minmax normalization
Lep_squam_range <- max(Lep_squam$X5) - min(Lep_squam$X5)
#Add the min_max normalized column
Lep_squam  <- mutate(Lep_squam, normal_mean = (X5 - min(X5))/ Lep_squam_range)
#Convert GC content to a percentage
Lep_squam  <- mutate(Lep_squam, GC_content = (X6 * 100))
#Make a position column for easy plotting
Lep_squam$position <- 1:nrow(Lep_squam)
#Filter dataset by the 8 largest contigs
Lep_squam_filtered <- Lep_squam %>% filter(X1 == "ptg000011l"| X1 == "ptg000030l" | X1 == "ptg000019l" | X1 == "ptg000001l" |  X1 == "ptg000057l" | X1 == "ptg000017l" | X1 == "ptg000009l" | X1 == "ptg000004l")

#This is necessary for annotating the x axis, this identifies all unique chromosomes/contigs 
chromosomes_Lep_squam  <- unique(Lep_squam_filtered[, c("X1", "position")])

unique_Lep_squam  <- chromosomes_Lep_squam[duplicated(chromosomes_Lep_squam$X1) == FALSE,]

#Save new edited file
write_tsv(Lep_squam, "Lep_squam.tsv")

#Map the coverage with respect to repeat content.
map_lep_squam <- ggplot(Lep_squam_filtered, aes(x = position)) + 
  geom_area(aes(y = X4/600), fill = "olivedrab", outline.type = "lower", alpha = 0.6) + #Repeat_percentage, notice the transformation, this is so that it can be added a second axis.
  geom_area(aes(y = normal_mean), fill = "gray", outline.type = "lower", alpha = 0.6) + #Normal mean coverage in gray.
  geom_vline(data = unique_Lep_squam, aes(xintercept = position), linetype = "dotted", alpha = 0.8, color = "black") + #This adds vertical lines at the start of every contig.
  coord_cartesian(ylim = c(0, 0.25)) +  #This value will need to be changed IF you removed outliers, if you don,t the graph has a few 100kb blocks with coverage that is too high to properly view the graph.
  theme_cowplot() +
  scale_y_continuous(name = "Normalized Mean Coverage",
                     sec.axis = sec_axis(trans=~.*600,name = "Repeat Percentage [%]")) + #Adds a second y-axis on the right which is a transformation of the first one, the relationship should be inverse.
  scale_x_continuous(
    breaks = unique_Lep_squam$position,  
    labels = unique_Lep_squam$X1  
  ) +
  theme(legend.position = "none") +
  theme(axis.title.x = element_text(size = 10, vjust = -0.5),
        axis.title.y = element_text(size = 10, colour = "gray"),
        axis.title.y.right = element_text(size = 10, colour = "olivedrab"),
        axis.text.y = element_text(size = 8),
        axis.title.x.bottom = element_blank(),
        axis.text.x = element_text(size = 8, hjust = 0, vjust = -0.09),
        legend.box = element_blank(),
        axis.text = element_text(size = 5)) +
  #If your dataset has outliers greatly above the mean this will annotate them, it will ad the normal mean values when they are out of bounds and add a segment pointing to them.
  geom_text(
    data = subset(Lep_squam_filtered , normal_mean > 0.25),
    aes(x = position - 22, y = 0.18, label = round(normal_mean, 2)),
    size = 2.5,
    color = "gray",
    angle = 30,
    vjust = 1.5,
    hjust = 1.2,
  ) +
  geom_segment(
    data = subset(Lep_squam_filtered , normal_mean > 0.25),
    aes(
      x = position - 20,
      xend = position,
      y = 0.18,
      yend = 0.21,
    ),
    color = "gray",
    linetype = "dotted"
  )

map_lep_squam

#Mapping coverage with respect to GC content on a secondary axis.
map_lep_squam_gc <- ggplot(Lep_squam_filtered, aes(x = position)) + 
  geom_area(aes(y = ((GC_content- 39)/150)), fill = "orange3", outline.type = "lower", alpha = 0.6) + #Mapping GC content, but we are doing an extra transformation on the axis so that GC content starts at the minimum of the dataset.
  geom_area(aes(y = normal_mean), fill = "gray", outline.type = "lower", alpha = 0.6) + #Mapping coverage
  geom_vline(data = unique_Lep_squam, aes(xintercept = position), linetype = "dotted", alpha = 0.8, color = "black") +  #Annotating the contig start positions as above.
  coord_cartesian(ylim = c(0, 0.25)) +  #Again this will need to be changed if outliers are added.
  theme_cowplot() +
  scale_y_continuous(name = "Normalized Mean Coverage",
                     sec.axis = sec_axis(trans = ~ .* 150 + 39, name = "GC Percentage [%]", #Notice the inverse transformation on the secondary axis.
                                         breaks = seq(20, 100, by = 5), labels = seq(20, 100, by = 5))) +
  scale_x_continuous(
    breaks = unique_Lep_squam$position,  
    labels = unique_Lep_squam$X1  
  ) +
  theme(legend.position = "none") +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_text(size = 10, colour = "gray"),
        axis.title.y.right = element_text(size = 10, colour = "orange3"),
        axis.text.y = element_text(size = 8),
        axis.text.x = element_text(size = 8, hjust = 0, vjust = -0.09),
        legend.box = element_blank(),
        axis.text = element_text(size = 50)) +
  geom_text(
    data = subset(Lep_squam_filtered, normal_mean > 0.25),
    aes(x = position - 22, y = 0.18, label = round(normal_mean, 2)),
    size = 2.5,
    color = "gray",
    angle = 30,
    vjust = 1.5,
    hjust = 1.2
  ) +
  geom_segment(
    data = subset(Lep_squam_filtered, normal_mean > 0.25),
    aes(
      x = position - 20,
      xend = position,
      y = 0.18,
      yend = 0.21,
    ),
    color = "gray",
    linetype = "dotted"
  )

map_lep_squam_gc

#Will map repeats with respect to GC content. 
gc_content_lep_squam <- ggplot(Lep_squam_filtered, aes(x = position)) +
  geom_line(aes(y = GC_content), color = "maroon") +
  geom_vline(data = unique_Lep_squam, aes(xintercept = position), linetype = "dotted", alpha = 0.8, color = "black") +
  geom_area(aes(y = X4/1), fill = "olivedrab", outline.type = "lower", alpha = 0.6) +
  theme_cowplot() +
  scale_y_continuous(name = "GC Content [%]",
                     sec.axis = sec_axis(trans=~.*1,name = "Repeat Percentage [%]")) +
  xlab(label = "8 Largest Contigs in 100kb Non-Overlapping Windows") +
  scale_x_continuous(
    breaks = unique_Lep_squam$position,  
    labels = unique_Lep_squam$X1  
  ) +
  coord_cartesian(ylim = c(0,100)) +
  theme_cowplot() +
  theme(legend.position = "none") +
  theme(axis.title.x = element_text(size = 10, vjust = -0.5),
        axis.title.y = element_text(size = 10, colour = "maroon"),
        axis.title.y.right = element_text(size = 10, colour = "olivedrab"),
        axis.text.y = element_text(size = 8),
        axis.text.x = element_text(size = 8, hjust = 0, vjust = -0.09),
        legend.box = element_blank(),
        axis.text = element_text(size = 5))

#Calculate all the coverage and SD for the datasets, as well as above and below mean GC content. 
mean_lep <- mean(Lep_squam$X5)
sd_lep <- sd(Lep_squam$X5)
mean_lep_high_gc <- mean(filter(Lep_squam, X6 >= 0.43)$X5)
sd_lep_high_gc <- sd(filter(Lep_squam, X6 >= 0.43)$X5)
mean_lep_low_gc <- mean(filter(Lep_squam, X6 <= 0.43)$X5)
sd_lep_low_gc <- sd(filter(Lep_squam, X6 <= 0.43)$X5)

#Calculate these values for graphing purposes:
mean_lep_normalized <- mean(Lep_squam$normal_mean)
sd_lep_normalized <- sd(Lep_squam$normal_mean)

#Make the point graph showing GC, conetn, coverage, and repeat percentage all the same graph.
gc_repeat_point_lep <- ggplot(Lep_squam, aes(x = GC_content, y = normal_mean)) +
  geom_hline(yintercept = mean_lep_normalized + sd_lep_normalized, color = "gray", size =1, alpha = 0.3) + #The hline and rect geoms are simply adding a box around the mean and one standard deviation above and below.
  geom_hline(yintercept = mean_lep_normalized - sd_lep_normalized, color = "gray", size =1, alpha = 0.3) +
  geom_rect(aes(xmin = -Inf, xmax = 100, ymin = mean_lep_normalized - sd_lep_normalized, ymax = mean_lep_normalized + sd_lep_normalized), fill = "whitesmoke", alpha = 0.9) +
  geom_point(aes(color = X4), position = "jitter") +
  scale_color_continuous(type = "viridis", name = "Repeat Percentage [%]") +
  theme_cowplot() +
  xlab("GC Content [%]") +
  ylab("Normalized Mean Coverage") +
  geom_hline(yintercept = mean_lep_normalized, color = "firebrick2", linetype = "dotted", size = 1.2) +
  coord_cartesian(xlim = c(25,60), ylim = c(0,.40))

gc_repeat_point_lep


#Save all the ggplot objects we created
save(gc_repeat_point_lep, file = "ggplot_objects/gc_repeat_point_lep")
save(map_lep_squam, file = "ggplot_objects/map_lep_squam")
save(gc_content_lep_squam, file = "ggplot_objects/gc_content_lep_squam")
save(map_lep_squam_gc, file = "ggplot_objects/map_lep_squam_gc")

