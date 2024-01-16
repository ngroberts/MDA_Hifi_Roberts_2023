library(ggplot2)
library(patchwork)

#Make the Lep_squam repeat content graph and add annotation
load("ggplot_objects/map_lep_squam_no_outliers")

lepidodermella_squamata_repeats_coverage_no_outliers <- map_lep_squam_no_outliers

png("Figures/Outliers_removed/lepidodermella_squamata_repeats_coverage_no_outliers.png",
    width = 170,
    height = 150,
    res = 300,
    units = "mm")

lepidodermella_squamata_repeats_coverage_no_outliers

dev.off()

#Make the Lep_squam GC graph and add annotation
load("ggplot_objects/map_lep_squam_gc_no_outliers")

lepidodermella_squamata_GC_coverage_no_outliers <- map_lep_squam_gc_no_outliers

png("Figures/Outliers_removed/lepidodermella_squamata_GC_coverage_no_outliers.png",
    width = 170,
    height = 150,
    res = 300,
    units = "mm")

lepidodermella_squamata_GC_coverage_no_outliers

dev.off()

#Make the C_elegans repeat graph and add annotation
load("ggplot_objects/map_amp_c_ele_no_outliers")
load("ggplot_objects/map_unamp_c_ele_no_outliers")

c_elegans_repeats_no_outliers <- map_amp_c_ele_no_outliers / map_unamp_c_ele_no_outliers +
  plot_annotation(
    tag_levels = 'A',
    title = expression(italic('Caenorhabditis elegans')),
  ) & 
  theme(plot.tag = element_text(size = 8),
        plot.title = element_text(size = 10))

png("Figures/Outliers_removed//C_elegans_repeats_coverage_no_outliers.png",
    width = 170,
    height = 225,
    res = 300,
    units = "mm")

c_elegans_repeats_no_outliers

dev.off

#Make the C_elegans GC graph and add annotation
load("ggplot_objects/map_amp_c_ele_gc_no_outliers")
load("ggplot_objects/map_unamp_c_ele_gc_no_outliers")

c_elegans_gc_no_outliers <- map_amp_c_ele_gc_no_outliers / map_unamp_c_ele_gc_no_outliers +
  plot_annotation(
    tag_levels = 'A',
    title = expression(italic('Caenorhabditis elegans')),
  ) & 
  theme(plot.tag = element_text(size = 8),
        plot.title = element_text(size = 10))

png("Figures/Outliers_removed/C_elegans_GC_coverage_no_outliers.png",
    width = 170,
    height = 225,
    res = 300,
    units = "mm")

c_elegans_gc_no_outliers

dev.off

#Make the C_elegans point cloud graph and add annotation
load("ggplot_objects/gc_repeat_point_amp_no_outliers")
load("ggplot_objects/gc_repeat_point_unamp_no_outliers")
load("ggplot_objects/gc_repeat_point_lep_no_outliers")

gc_repeat_point_amp_graph_no_outliers <- gc_repeat_point_amp_no_outliers + theme(axis.title.x = element_blank())
gc_repeat_point_unamp_graph_no_outliers <- gc_repeat_point_unamp_no_outliers + theme(axis.title.y = element_blank(),
                                                             axis.line.y = element_blank(),
                                                             axis.text.y = element_blank(),
                                                             axis.ticks.y = element_blank())
                
gc_repeat_point_lep_graph_no_outliers <- gc_repeat_point_lep_no_outliers + 
  scale_colour_continuous(type = "viridis", name = "Repeat Percentage [%]", limits = c(0,100)) 

repeat_point_cloud_C_elegans_no_outliers  <- (gc_repeat_point_amp_graph_no_outliers  + gc_repeat_point_unamp_graph_no_outliers )

repeat_gc_cloud_no_outliers  <- (repeat_point_cloud_C_elegans_no_outliers  / gc_repeat_point_lep_graph_no_outliers ) + 
  plot_annotation(tag_levels = "A") &
  theme(text = element_text(size = 8),
        axis.text = element_text(size = 8),
        axis.title = element_text(size = 8),
        plot.tag = element_text(size = 8),
        ) &
  scale_color_continuous(limits = c(0,100),
                         type = "viridis",
                         name = "Repeat Percentage [%]")
  
repeat_gc_cloud + plot_layout(guides = "collect")


png("Figures/Outliers_removed/Point_cloud_all_plots_no_outliers.png",
    width = 170,
    height = 165,
    res = 300,
    units = "mm")

repeat_gc_cloud_no_outliers  + plot_layout(guides = "collect")

dev.off()

