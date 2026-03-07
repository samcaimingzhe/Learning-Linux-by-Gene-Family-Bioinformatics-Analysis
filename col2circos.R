library(tidyverse)

gff = read.csv('md.wgdi.gff',sep='\t',header=F)
col = read.csv('md.md.colgenes',sep='\t',header=F)
names(gff) = c("chr","gene","start","end","direction","n","old")
gff0 = gff |> select(chr,gene,start,end)

col$order <- 1:nrow(col)
col1 = col[, c("order", "V1")]
col2 = col[, c("order", "V2")]
names(col1) = c("order", "gene")
names(col2) = c("order", "gene")

loc1 = merge(col1, gff0, by = 'gene')
loc2 = merge(col2, gff0, by = 'gene')

final0 = merge(loc1, loc2, by = 'order')
final0$color = "color=dpurple,thickness=3"
final = final0 |> select(chr.x,start.x,end.x,chr.y,start.y,end.y,color)

write.table(final, "for_circos.txt", sep = "\t", 
            row.names = FALSE, col.names = FALSE, quote = FALSE)

            
