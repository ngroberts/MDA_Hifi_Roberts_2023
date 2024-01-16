#Load libraries
library(ggplot2)
library(tidyverse)
library(aplot)
library(treeio)
library(ggtree)
library(ggthemes)
library(ape)


#Read a tree from a newick string, in this case its custom.
tree_1 <- ape::read.tree(text='((((((((Annelida), Nemertea),(Brachiopoda,(Phoronida,Bryozoa))),(((((((Mollusca),(Entoprocta,Cycliophora))))),(((Platyhelminthes), Gastrotricha)),(((Rotifera, Micrognathozoa),Gnathostomulida), Chaetognatha)),(Outgroup)))))));')
tree_1 <- root(tree_1, outgroup = "Outgroup")
tree_1


#Make into ggtree object, with the labels and limits modified to fit

tree <- ggtree(tree_1) + geom_tiplab(size = 3, geom = "text", offset = 2, hjust = "right")
tree

#Read in a csv of buscos
buscos <- read.csv("busco_summary_fig1.csv")

#Modify to match the formatting of the data in the tree object
buscos <- mutate(buscos, complete = Single + Duplicated)
buscos <- rename_with(buscos, ~ tolower(gsub(".", "", .x, fixed = TRUE)))
buscos <- rename_with(buscos, ~ tolower(gsub(" ", "", .x, fixed = TRUE)))
buscos <- buscos %>% select(taxon, single, duplicated)
buscos <- rename(buscos, label = taxon)

#Pivot longer to be able to make a stacked bar graph
busco_long <- drop_na(pivot_longer(buscos, single:duplicated, names_to = "svd", values_to = "perc_genes"))

busco_long <- busco_long %>% mutate(across(where(is.character), str_trim))

#Make a bar graph
busco_bar <- ggplot(busco_long, aes(x = label, perc_genes, fill = svd, label = perc_genes)) +
geom_bar(position="stack", stat = "identity") +
geom_text(size = 3, position = position_stack(vjust = 0.5)) +
ylim(0,100) +
theme(axis.text.x=element_blank(),
axis.text.y=element_blank(),
axis.line=element_blank(),
axis.ticks=element_blank(),
axis.title.x=element_blank(),
axis.title.y=element_blank(),
legend.position="none",
panel.background=element_blank(),
panel.border=element_blank(),
panel.grid.major=element_blank(),
panel.grid.minor=element_blank(),
plot.background=element_blank()) +
coord_flip()

busco_bar

#Use aplot functionaility to add barplot to tree
busco_bar %>% insert_left(tree, width = 4)

