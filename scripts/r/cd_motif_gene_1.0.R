################################
###### Configure of Plot #######
################################
WIDTH_OF_PLOT  = 12
HEIGHT_OF_PLOT = 6
DPI_OF_PNG     = 600
PROPORTION_OF_EACH = c(1, 1, 1, 2)
FILENAME_PREFIX = "tree_motif_cd_gene"
MOTIF_FILTER = c('motif_1','motif_2','motif_3','motif_4','motif_5',
                 'motif_6','motif_7','motif_8','motif_9','motif_10')
CD_FILTER = c('PLN03193','PLN03133','Senescence_reg','Galactosyl_T',
              'AKR_SF','DUF4094','DUF604','dimerization','AdoMet_MTases')
################################
### Installation of packages ###
################################
if (!require("tidyverse", quietly = TRUE)) {
  install.packages("tidyverse", force = TRUE)
}
library(tidyverse)
### ggmotif install ###
if (!require("BiocManager", quietly = TRUE)){
  install.packages("BiocManager", force = TRUE)
}
library(BiocManager)

if (!require("ggmotif", quietly = TRUE)) {
  deps <- c("XML", "ggtree", "ape", "ggseqlogo", "memes", 
            "universalmotif", "treeio", "cowplot", "ggsci")
  BiocManager::install(deps)
  install.packages("ggmotif_0.2.1.tar.gz", repos = NULL, type = "source")
}
library(ggmotif)

if (!require("ggthemes", quietly = TRUE)) {
  install.packages("ggthemes", force = TRUE)
}
library(ggthemes)

if (!require("ggtree", quietly = TRUE)) {
  BiocManager::install("ggtree", force = TRUE)
}
library(ggtree)

if (!require("patchwork", quietly = TRUE)) {
  install.packages("patchwork", force = TRUE)
}
library(patchwork)
################################
### Processing and Plotting ####
################################
fancy_color = c("#5086C4", "#B55489", "#4C6C43", "#F0A19A", 
                "#7C7CBA", "#00A664", "#F9ED1D", "#3FA0C0", 
                "#D5D9E5", "#D6E0C8", "#FEDEC5", "#FFF0BC", 
                "#C7B8BD")
# File loading
motif = getMotifFromMEME(data = 'meme.xml', format = 'xml')
motif_base = motif |> select(input.seq.id,length,motif_id,start.position,end.position)
names(motif_base) = c('ID','protein.length','Motif_ID','motif.start','motif.end')

cds.pos = read.csv('Md.galt.cds.pos',sep = '\t', header = F)
names(cds.pos) = c('cds.start','cds.end','Old_ID')

mrna.pos = read.csv('Md.galt.mrna.pos',sep = '\t', header = F)
names(mrna.pos) = c('mrna.start','mrna.end','Old_ID')

id = read.csv('rename.id',sep = '\t', header = F)
names(id) = c('Old_ID','ID')

cd = read.csv('cd.info',sep = '\t', header = F)
names(cd) = c('ID','cd.start','cd.end','domain')

tree = read.tree("Md.renamed.galt.phb")
# ggtree(tree, branch.length = "none") + xlim(0, 11) +geom_tiplab(size = 3)
ptree = ggtree(tree, branch.length = "none")

sum_of_info = merge(
  merge(
    merge(
      merge(cds.pos, mrna.pos, by = 'Old_ID'), id, by = 'Old_ID'),
    motif_base, by = 'ID'), cd, by = 'ID')

sum_of_info = sum_of_info |> mutate('gene.start' = cds.start - mrna.start,
                                    'gene.end' = cds.end - mrna.start,
                                    'gene.length' = mrna.end - mrna.start) |>
  select(-cds.start,-cds.end,-mrna.start,-mrna.end,-Old_ID)

# str(sum_of_info)
sum_of_info$protein.length = as.numeric(sum_of_info$protein.length)
id_order = tree$tip.label
sum_of_info$ID = factor(sum_of_info$ID, levels = tree$tip.label)

sum_of_info = sum_of_info |> filter(Motif_ID %in% MOTIF_FILTER & domain %in% CD_FILTER)

pcd = ggplot(sum_of_info, aes(y = ID)) +
  geom_segment(aes(x = 0, xend = protein.length, y = ID, yend = ID), 
               color = "grey80", size = 1) +
  geom_segment(aes(x = cd.start, xend = cd.end, y = ID, yend = ID, color = domain), 
               size = 3) + 
  theme_tufte() +
  labs(x = "Protein Length (aa)\nConserved Domain", 
       color = "Domain Type")+
  scale_color_manual(values=fancy_color)+
  theme(
    axis.text.y = element_blank(),
    axis.title.y = element_blank(),
    legend.position = 'none'
  )

pmotif = ggplot(sum_of_info, aes(y = ID)) +
  geom_segment(aes(x = 0, xend = protein.length, y = ID, yend = ID), 
               color = "grey80", size = 1) +
  geom_segment(aes(x = motif.start, xend = motif.end, y = ID, yend = ID, color = Motif_ID), 
               size = 3) + 
  theme_tufte() +
  labs(x = "Protein Length (aa)\nConserved Motif", 
       y = "Gene/Protein ID", 
       color = "Motif Type")+
  scale_color_manual(values=fancy_color)+
  theme(
    axis.title.y = element_blank(),
    legend.position = 'none'
  )

pgene = ggplot(sum_of_info, aes(y = ID)) +
  geom_segment(aes(x = 0, xend = gene.length, y = ID, yend = ID), 
               color = "grey90", linewidth = 1) +
  geom_segment(aes(x = gene.start, xend = gene.end, y = ID, yend = ID), 
               color = "springgreen4", linewidth = 3) + 
  theme_tufte() +
  labs(x = "DNA Length (bp)\nGene Structure")+
  theme(
    axis.text.y = element_blank(),
    axis.title.y = element_blank(),
    legend.position = 'none'
  )

pmerge = ptree + pmotif + pcd + pgene + 
  plot_layout(widths = PROPORTION_OF_EACH)

save_plots = function(p,prefix) {
  ggsave(
    filename = paste0(prefix, ".png"),
    plot = p,
    width = WIDTH_OF_PLOT, height = HEIGHT_OF_PLOT, dpi = DPI_OF_PNG, bg = "white"
  )
  
  ggsave(
    filename = paste0(prefix, ".pdf"),
    plot = p,
    width = WIDTH_OF_PLOT, height = HEIGHT_OF_PLOT, bg = "white"
  )
}

save_single = function(p,prefix) {
  ggsave(
    filename = paste0(prefix, ".png"),
    plot = p,
    width = HEIGHT_OF_PLOT, height = HEIGHT_OF_PLOT, dpi = DPI_OF_PNG, bg = "white"
  )
  
  ggsave(
    filename = paste0(prefix, ".pdf"),
    plot = p,
    width = HEIGHT_OF_PLOT, height = HEIGHT_OF_PLOT, bg = "white"
  )
}

save_plots(pmerge,FILENAME_PREFIX)
save_single(pmotif+theme(axis.text.y = element_text(),
                        legend.position = 'right'),
           "motif")
save_single(pcd+theme(axis.text.y = element_text(),
                     legend.position = 'right'),
           "cd")
save_single(pgene+theme(axis.text.y = element_text(),
                       legend.position = 'right'),
           "gene")
