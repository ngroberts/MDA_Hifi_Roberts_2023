library(ggplot2)
library(patchwork)

#Make the Lep_squam repeat content graph and add annotation
load("ggplot_objects/map_lep_squam")

lepidodermella_squamata_repeats_coverage <- map_lep_squam

png("Figures/Outliers_kept/lepidodermella_squamata_repeats_coverage.png",
    width = 170,
    height = 150,
    res = 300,
    units = "mm")

lepidodermella_squamata_repeats_coverage

dev.off()

#Make the Lep_squam GC graph and add annotation
load("ggplot_objects/map_lep_squam_gc")

lepidodermella_squamata_GC_coverage <- map_lep_squam_gc

png("Figures/Outliers_kept/lepidodermella_squamata_GC_coverage.png",
    width = 170,
    height = 150,
    res = 300,
    units = "mm")

lepidodermella_squamata_GC_coverage

dev.off()

#Make the C_elegans repeat graph and add annotation
load("ggplot_objects/map_amp_c_ele")
load("ggplot_objects/map_unamp_c_ele")

c_elegans_repeats <- map_amp_c_ele / map_unamp_c_ele +
  plot_annotation(
    tag_levels = 'A',
    title = expression(italic('Caenorhabditis elegans')),
  ) & 
  theme(plot.tag = element_text(size = 8),
        plot.title = element_text(size = 10))

png("Figures/Outliers_kept/C_elegans_repeats_coverage.png",
    width = 170,
    height = 225,
    res = 300,
    units = "mm")

c_elegans_repeats

dev.off

#Make the C_elegans GC graph and add annotation
load("ggplot_objects/map_amp_c_ele_gc")
load("ggplot_objects/map_unamp_c_ele_gc")

c_elegans_gc <- map_amp_c_ele_gc / map_unamp_c_ele_gc +
  plot_annotation(
    tag_levels = 'A',
    title = expression(italic('Caenorhabditis elegans')),
  ) & 
  theme(plot.tag = element_text(size = 8),
        plot.title = element_text(size = 10))

png("Figures/Outliers_kept/C_elegans_GC_coverage.png",
    width = 170,
    height = 225,
    res = 300,
    units = "mm")

c_elegans_gc

dev.off

#Make the C_elegans point cloud graph and add annotation
load("ggplot_objects/gc_repeat_point_amp")
load("ggplot_objects/gc_repeat_point_unamp")
load("ggplot_objects/gc_repeat_point_lep")
load("ggplot_objects/lorenz_total")

gc_repeat_point_amp_graph <- gc_repeat_point_amp + theme(axis.title.x = element_blank())
gc_repeat_point_unamp_graph <- gc_repeat_point_unamp + theme(axis.title.y = element_blank(),
                                                             axis.line.y = element_blank(),
                                                             axis.text.y = element_blank(),
                                                             axis.ticks.y = element_blank())
                
gc_repeat_point_lep_graph <- gc_repeat_point_lep + 
scale_colour_continuous(type = "viridis", name = "Repeat Percentage [%]", limits = c(0,100)) 

repeat_point_cloud_C_elegans_amp <- gc_repeat_point_amp_graph &
  scale_color_continuous(limits = c(0,100),
                         type = "viridis",
                         name = "Repeat Percentage [%]")
repeat_point_cloud_C_elegans_unamp <- gc_repeat_point_unamp_graph &
  scale_color_continuous(limits = c(0,100),
                         type = "viridis",
                         name = "Repeat Percentage [%]")
repeat_point_cloud_Leop_squam <- gc_repeat_point_lep_graph &
  scale_color_continuous(limits = c(0,100),
                         type = "viridis",
                         name = "Repeat Percentage [%]")
lorenz_total <- lorenz_total &
  annotate("text", x = 0.13, y = 1, label = "Gini Index:", size = 1.5) &
  annotate("text", x = 0.06, y = 0.95, label = "Lepidodermella squamata = 0.29", hjust = 0, fontface = "italic", size = 1.5) &
  annotate("text", x = 0.06, y = 0.92, label = "Caenorhabditis elegans MDA = 0.14", hjust = 0, fontface = "italic", size = 1.5) &
  annotate("text", x = 0.06, y = 0.89, label = "Caenorhabditis elegans = 0.16", hjust =0, fontface = "italic", size = 1.5) &
  geom_point(aes(x = 0.04, y = 0.95), colour = "cyan", size = 1) &
  geom_point(aes(x = 0.04, y = 0.92), colour = "chartreuse", size = 1) &
  geom_point(aes(x = 0.04, y = 0.89), colour = "red", size = 1) &
  theme(legend.position = "none")

lorenz_total

repeat_gc_cloud <- ((repeat_point_cloud_C_elegans_amp + repeat_point_cloud_C_elegans_unamp) / (gc_repeat_point_lep_graph + lorenz_total)) + 
  plot_annotation(tag_levels = "A") &
  theme(text = element_text(size = 8),
        axis.text = element_text(size = 8),
        axis.title = element_text(size = 8),
        plot.tag = element_text(size = 8),
        ) 


png("Figures/Outliers_kept/Point_cloud_all_plots.png",
    width = 170,
    height = 165,
    res = 300,
    units = "mm")

repeat_gc_cloud + plot_layout(guides = "collect") &
  theme(text = element_text(size = 8),
        axis.text = element_text(size = 8),
        axis.title = element_text(size = 8),
        plot.tag = element_text(size = 8),
        
  ) 


dev.off()

