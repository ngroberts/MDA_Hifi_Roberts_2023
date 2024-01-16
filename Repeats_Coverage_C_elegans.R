library(ggplot2)
library(tidyverse)
library(cowplot)
library(patchwork)
library(ggpmisc)
library(stats)
library(RColorBrewer)
library(ggstatsplot)

#Load in bedfiles
C_bed_repeat_unamped <- read_tsv("C_elegans_GC_repeats_coverage_unamped.bed", col_names = FALSE)
C_bed_repeat_amped <- read_tsv("C_elegans_GC_repeats_coverage_amped.bed", col_names = FALSE)

#Remove outliers using 1.5* IQR for coverage comment out this block to keep outliers.
#amplified
# Q_amp <- quantile(C_bed_repeat_amped$X5, probs=c(.25, .75), na.rm = FALSE)
# iqr_amp <- IQR(C_bed_repeat_amped$X5)
# up_amp <- Q[2]+1.5*iqr
# low_amp <- Q[1]-1.5*iqr
# 
# C_bed_repeat_amped <- C_bed_repeat_amped %>% filter(X5 < up_amp, X5 > low_amp)
# 
# #Nonamplified
# Q_unamp <- quantile(C_bed_repeat_unamped$X5, probs=c(.25, .75), na.rm = FALSE)
# iqr_unamp <- IQR(C_bed_repeat_unamped$X5)
# up_unamp <- Q[2]+1.5*iqr
# low_unamp <- Q[1]-1.5*iqr

# C_bed_repeat_unamped <- C_bed_repeat_unamped %>% filter(X5 < up_unamp, X5 > low_unamp)

#Find the range of the coverage for minmax normalization
C_bed_range_amp <- max(C_bed_repeat_amped$X5) - min(C_bed_repeat_amped$X5)
C_bed_range_unamp <- max(C_bed_repeat_unamped$X5) - min(C_bed_repeat_unamped$X5)

#Add the min_max normalized column
C_bed_repeat_amped <- mutate(C_bed_repeat_amped, normal_mean = (X5 - min(X5))/ C_bed_range_amp)
C_bed_repeat_unamped <- mutate(C_bed_repeat_unamped, normal_mean = (X5 - min(X5))/ C_bed_range_unamp)

#Convert GC content to a percentage
C_bed_repeat_amped <- mutate(C_bed_repeat_amped, GC_content = (X6)*100)
C_bed_repeat_unamped <- mutate(C_bed_repeat_unamped, GC_content = (X6)*100)

#Make a position column for easy plotting
C_bed_repeat_unamped$position <- 1:nrow(C_bed_repeat_unamped)
C_bed_repeat_amped$position <- 1:nrow(C_bed_repeat_amped)

#This is necessary for annotating the x axis, this identifies all unique chromosomes 
chromosomes_amp <- unique(C_bed_repeat_amped[, c("X1", "position")])
chromosomes_unamp <- unique(C_bed_repeat_unamped[, c("X1", "position")])

unique_amp <- chromosomes_amp[duplicated(chromosomes_amp$X1) == FALSE, ]
unique_unamp <- chromosomes_unamp[duplicated(chromosomes_unamp$X1) == FALSE, ]

#Save these new edited files
write_tsv(C_bed_repeat_unamped, "C_bed_repeat_unamped.tsv")
write_tsv(C_bed_repeat_amped, "C_bed_repeat_amped.tsv")


#Map the uanmplified coverage with respect to repeat content.
map_unamp_c_ele <- ggplot(C_bed_repeat_unamped, aes(x = position)) + 
  geom_area(aes(y = X4/400), fill = "blue", outline.type = "lower", alpha = 0.6) + #Repeat_percentage, notice the transformation, this is so that it can be added a second axis.
  geom_area(aes(y = normal_mean), fill = "gray", outline.type = "lower", alpha = 0.6) + #Normal mean coverage in gray.
  geom_vline(data = unique_unamp, aes(xintercept = position), linetype = "dotted", alpha = 0.8, color = "black") + #This adds vertical lines at the start of every chromosome.
  coord_cartesian(ylim = c(0,.2)) + #This value will need to be changed IF you removed outliers, if you don,t the graph has a few 100kb blocks with coverage that is too high to properly view the graph.
  theme_cowplot() +
  scale_y_continuous(name = "Normalized Mean Coverage",
                     sec.axis = sec_axis(trans=~.*400,name = "Repeat Percentage [%]")) + #Adds a second y-axis on the right which is a transformation of the first one, the relationship should be inverse.
  scale_x_continuous(
    breaks = unique_unamp$position,  
    labels = unique_unamp$X1  
  ) +
  theme(legend.position = "none") +
  theme(axis.title.x = element_text(size = 10, vjust = -0.5),
        axis.title.y = element_text(size = 10, colour = "gray"),
        axis.title.y.right = element_text(size = 10, colour = "blue"),
        axis.text.y = element_text(size = 8),
        axis.title.x.bottom = element_blank(),
        axis.text.x = element_text(size = 8, hjust = 0, vjust = -0.09),
        legend.box = element_blank(),
        axis.text = element_text(size = 5)) +
 #If your dataset has outliers greatly above the mean this will annotate them, it will ad the normal mean values when they are out of bounds and add a segment pointing to them.
 geom_text(
   data = subset(C_bed_repeat_unamped, normal_mean > 0.2),
   aes(x = position - 22, y = 0.18, label = round(normal_mean, 2)),
   size = 2.5,
   color = "gray",
   angle = 30,
   vjust = 1.5,
   hjust = 1.2
 ) +
 geom_segment(
   data = subset(C_bed_repeat_unamped, normal_mean > 0.2),
   aes(
     x = position - 20,
     xend = position,
     y = 0.18,
     yend = 0.21,
   ),
   color = "gray",
   linetype = "dotted"
 )

map_unamp_c_ele

#Same as above just with amplified coverage.
map_amp_c_ele <- ggplot(C_bed_repeat_amped, aes(x = position)) + 
  geom_area(aes(y = X4/400), fill = "blue", outline.type = "lower", alpha = 0.6) +
  geom_area(aes(y = normal_mean), fill = "gray", outline.type = "lower", alpha = 0.6) +
  geom_vline(data = unique_amp, aes(xintercept = position), linetype = "dotted", alpha = 0.8, color = "black") + 
  coord_cartesian(ylim = c(0,0.2)) +  
  theme_cowplot() +
  scale_y_continuous(name = "Normalized Mean Coverage",
                     sec.axis = sec_axis(trans=~.*400,name = "Repeat Percentage [%]")) +
  scale_x_continuous(
    breaks = unique_amp$position,  
    labels = unique_amp$X1  
  ) +
  theme(legend.position = "none") +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_text(size = 10, colour = "gray"),
        axis.title.y.right = element_text(size = 10, colour = "blue"),
        axis.text.y = element_text(size = 8),
        axis.text.x = element_text(size = 8, hjust = 0, vjust = -0.09),
        legend.box = element_blank(),
        axis.text = element_text(size = 5)) +
  #If your dataset has outliers greatly above the mean this will annotate them.
  geom_text(
    data = subset(C_bed_repeat_amped, normal_mean > 0.2),
    aes(x = position - 22, y = 0.18, label = round(normal_mean, 2)),
    size = 2.5,
    color = "gray",
    angle = 30,
    vjust = 1.5,
    hjust = 1.2
  ) +
  geom_segment(
    data = subset(C_bed_repeat_amped, normal_mean > 0.2),
    aes(
      x = position - 20,
      xend = position,
      y = 0.18,
      yend = 0.21,
    ),
    color = "gray",
    linetype = "dotted"
  )

map_amp_c_ele


#Will map repeats with respect to GC content. 
gc_content_c_ele <- ggplot(C_bed_repeat_amped, aes(x = position)) +
  geom_line(aes(y = GC_content), color = "maroon") + #Map a line of gc content.
  geom_vline(data = unique_unamp, aes(xintercept = position), linetype = "dotted", alpha = 0.8, color = "black") +
  geom_area(aes(y = X4/1), fill = "blue", outline.type = "lower", alpha = 0.6) + #Same as above.
    geom_vline(data = unique_unamp, aes(xintercept = position), linetype = "dotted", alpha = 0.8, color = "black") + 
  theme_cowplot() +
  scale_y_continuous(name = "GC Content [%]",
                     sec.axis = sec_axis(trans=~.*1,name = "Repeat Percentage [%]")) + #Adding a second axis.
  xlab(label = "Chromosomes in 100kb Non-Overlapping Windows") +
  scale_x_continuous(
    breaks = unique_amp$position,  
    labels = unique_amp$X1  
  ) +
  coord_cartesian(ylim = c(0,100)) +
  theme_cowplot() +
  theme(legend.position = "none") +
  theme(axis.title.x = element_text(size = 10, vjust = -0.5),
        axis.title.y = element_text(size = 10, colour = "maroon"),
        axis.title.y.right = element_text(size = 10, colour = "blue"),
        axis.text.y = element_text(size = 8),
        axis.text.x = element_text(size = 8, hjust = 0, vjust = -0.09),
        legend.box = element_blank(),
        axis.text = element_text(size = 5))

gc_content_c_ele

#Mapping amplified coverage with respect to GC content on a secondary axis.
map_amp_c_ele_gc <- ggplot(C_bed_repeat_amped, aes(x = position)) + 
  geom_area(aes(y = ((GC_content- 30)/200)), fill = "orange3", outline.type = "lower", alpha = 0.6) + #Mapping GC content, but we are doing an extra transformation on the axis so that GC content starts at the minimum of the dataset.
  geom_area(aes(y = normal_mean), fill = "gray", outline.type = "lower", alpha = 0.6) + #Mapping coverage
  geom_vline(data = unique_amp, aes(xintercept = position), linetype = "dotted", alpha = 0.8, color = "black") + #Annotating the chromosome start positions as above.
  coord_cartesian(ylim = c(0, 0.2)) + #Again this will need to be changed if outliers are added.
  theme_cowplot() +
  scale_y_continuous(name = "Normalized Mean Coverage",
                     sec.axis = sec_axis(trans = ~ .* 200 + 30, name = "GC Percentage [%]", #Notice the inverse transformation on the secondary axis.
                                         breaks = seq(25, 100, by = 5), labels = seq(25, 100, by = 5))) +
  scale_x_continuous(
    breaks = unique_amp$position,  
    labels = unique_amp$X1  
  ) +
  theme(legend.position = "none") +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_text(size = 10, colour = "gray"),
        axis.title.y.right = element_text(size = 10, colour = "orange3"),
        axis.text.y = element_text(size = 8),
        axis.text.x = element_text(size = 8, hjust = 0, vjust = -0.09),
        legend.box = element_blank(),
        axis.text = element_text(size = 50)) +
  #If your dataset has outliers greatly above the mean this will annotate them as above.
  geom_text(
    data = subset(C_bed_repeat_amped, normal_mean > 0.2),
    aes(x = position - 22, y = 0.18, label = round(normal_mean, 2)),
    size = 2.5,
    color = "gray",
    angle = 30,
    vjust = 1.5,
    hjust = 1.2
  ) +
  geom_segment(
    data = subset(C_bed_repeat_amped, normal_mean > 0.2),
    aes(
      x = position - 20,
      xend = position,
      y = 0.18,
      yend = 0.21,
    ),
    color = "gray",
    linetype = "dotted"
  )
map_amp_c_ele_gc

#Mapping amlified coverage with respect to GC content on a secondary axis as above,
map_unamp_c_ele_gc <- ggplot(C_bed_repeat_unamped, aes(x = position)) + 
  geom_area(aes(y = ((GC_content- 30)/200)), fill = "orange3", outline.type = "lower", alpha = 0.6) +
  geom_area(aes(y = normal_mean), fill = "gray", outline.type = "lower", alpha = 0.6) +
  geom_vline(data = unique_unamp, aes(xintercept = position), linetype = "dotted", alpha = 0.8, color = "black") + 
  coord_cartesian(ylim = c(0, 0.2)) +  
  theme_cowplot() +
  scale_y_continuous(name = "Normalized Mean Coverage",
                     sec.axis = sec_axis(trans = ~ .* 200 + 30, name = "GC Percentage [%]",
                                         breaks = seq(20, 100, by = 5), labels = seq(20, 100, by = 5))) +
  scale_x_continuous(
    breaks = unique_unamp$position,  
    labels = unique_unamp$X1  
  ) +
  theme(legend.position = "none") +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_text(size = 10, colour = "gray"),
        axis.title.y.right = element_text(size = 10, colour = "orange3"),
        axis.text.y = element_text(size = 8),
        axis.text.x = element_text(size = 8, hjust = 0, vjust = -0.09),
        legend.box = element_blank(),
        axis.text = element_text(size = 50)) +
  #If your dataset has outliers greatly above the mean this will annotate them.
  geom_text(
    data = subset(C_bed_repeat_unamped, normal_mean > 0.2),
    aes(x = position - 22, y = 0.18, label = round(normal_mean, 2)),
    size = 2.5,
    color = "gray",
    angle = 30,
    vjust = 1.5,
    hjust = 1.2
  ) +
  geom_segment(
    data = subset(C_bed_repeat_amped, normal_mean > 0.2),
    aes(
      x = position - 20,
      xend = position,
      y = 0.18,
      yend = 0.21,
    ),
    color = "gray",
    linetype = "dotted"
  )

map_unamp_c_ele_gc / map_amp_c_ele_gc

map_unamp_c_ele / map_amp_c_ele

#Calculate all the coverage and SD for the datasets, as well as above and below mean GC content. 
#For amplified dataset.
mean_amp <- mean(C_bed_repeat_amped$X5)
sd_amp <- sd(C_bed_repeat_amped$X5)
mean_amp_high_gc <- mean(filter(C_bed_repeat_amped, X6 >= 0.35)$X5)
sd_amp_high_gc <- sd(filter(C_bed_repeat_amped, X6 >= 0.35)$X5)
mean_amp_low_gc <- mean(filter(C_bed_repeat_amped, X6 <= 0.35)$X5)
sd_amp_low_gc <- sd(filter(C_bed_repeat_amped, X6 <= 0.35)$X5)

#For non_amplified dataset
mean_unamp <- mean(C_bed_repeat_unamped$X5)
sd_unamp <- sd(C_bed_repeat_unamped$X5)
mean_unamp_high_gc <- mean(filter(C_bed_repeat_unamped, X6 >= 0.35)$X5)
sd_unamp_high_gc <- sd(filter(C_bed_repeat_unamped, X6 >= 0.35)$X5)
mean_unamp_low_gc <- mean(filter(C_bed_repeat_unamped, X6 <= 0.35)$X5)
sd_unamp_low_gc <- sd(filter(C_bed_repeat_unamped, X6 <= 0.35)$X5)

#Calculate these values for graphing purposes:
mean_amp_normalized <- mean(C_bed_repeat_amped$normal_mean)
sd_amp_normalized <- sd(C_bed_repeat_amped$normal_mean)


#Make the point graph showing GC, conetn, coverage, and repeat percentage all the same graph.
gc_repeat_point_amp <- ggplot(C_bed_repeat_amped, aes(x = GC_content, y = normal_mean)) +
  geom_hline(yintercept = mean_amp_normalized + sd_amp_normalized, color = "gray", size =1, alpha = 0.3) + #The hline and rect geoms are simply adding a box around the mean and one standard deviation above and below.
  geom_hline(yintercept = mean_amp_normalized - sd_amp_normalized, color = "gray", size =1, alpha = 0.3) +
  geom_rect(xmin = 0, xmax = 100, ymin = mean_amp_normalized - sd_amp_normalized, ymax = mean_amp_normalized + sd_amp_normalized, fill = "whitesmoke", alpha = 0.09) + #Geom rect is used instead of ribbon as it looks better,
  geom_hline(yintercept = mean_amp_normalized, color = "firebrick2", linetype = "dotted", size = 1.2) + #Add dotted line around mean coverage.
  geom_point(aes(color = X4), position = "jitter") + #Make the points colored by repeat percentage
  scale_color_continuous(type = "viridis", name = "Repeat Percentage [%]") +
  theme_cowplot() +
  ylab("Normalized Mean Coverage") +
  coord_cartesian(xlim = c(25,45), ylim = c(0,0.20)) #Again this needs to be changed if you removed outliers.

gc_repeat_point_amp

#Calculate these values for graphing purposes:
mean_unamp_normalized <- mean(C_bed_repeat_unamped$normal_mean)
sd_unamp_normalized <- sd(C_bed_repeat_unamped$normal_mean)

#Make the point graph showing GC, conetn, coverage, and repeat percentage all the same graph.
gc_repeat_point_unamp <- ggplot(C_bed_repeat_unamped, aes(x = GC_content, y = normal_mean), size = 1) +
  geom_hline(yintercept = mean_unamp_normalized + sd_unamp_normalized, color = "gray", size =1, alpha = 0.3) + 
  geom_hline(yintercept = mean_unamp_normalized - sd_unamp_normalized, color = "gray", size =1, alpha = 0.3) +
  geom_rect(xmin = 0, xmax = 100, ymin = mean_unamp_normalized - sd_unamp_normalized, ymax = mean_unamp_normalized + sd_unamp_normalized, fill = "whitesmoke", alpha = 0.09) +
  geom_point(aes(color = X4), position = "jitter") +
  scale_color_continuous(type = "viridis", name = "Repeat Percentage [%]") +
  theme_cowplot() +
  xlab("GC Content [%]") +
  ylab("Normalized Mean Coverage") +
  geom_hline(yintercept = mean_unamp_normalized, color = "firebrick2", linetype = "dotted", size = 1.2) +
  coord_cartesian(xlim = c(25,45), ylim = c(0,0.25))
gc_repeat_point_unamp


#Save all the ggplot objects we created
save(map_unamp_c_ele, file = "ggplot_objects/map_unamp_c_ele")
save(map_amp_c_ele, file = "ggplot_objects/map_amp_c_ele")
save(gc_content_c_ele, file = "ggplot_objects/gc_content_c_ele")
save(gc_repeat_point_amp, file = "ggplot_objects/gc_repeat_point_amp")
save(gc_repeat_point_unamp, file = "ggplot_objects/gc_repeat_point_unamp")
save(map_unamp_c_ele_gc, file = "ggplot_objects/map_unamp_c_ele_gc")
save(map_amp_c_ele_gc, file = "ggplot_objects/map_amp_c_ele_gc")


